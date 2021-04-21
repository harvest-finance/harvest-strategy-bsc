// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "./VenusInteractorInitializableV2.sol";
import "../interface/IVault.sol";
import "../upgradability/BaseUpgradeableStrategy.sol";

import "../interface/pancakeswap/IPancakeRouter02.sol";

contract VenusFoldStrategyV2 is BaseUpgradeableStrategy, VenusInteractorInitializableV2 {

  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  event ProfitNotClaimed();
  event TooLowBalance();

  address constant public pancakeswapRouterV2 = address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);

  // additional storage slots (on top of BaseUpgradeableStrategy ones) are defined here
  bytes32 internal constant _COLLATERALFACTORNUMERATOR_SLOT = 0x129eccdfbcf3761d8e2f66393221fa8277b7623ad13ed7693a0025435931c64a;
  bytes32 internal constant _FACTORDENOMINATOR_SLOT = 0x4e92df66cc717205e8df80bec55fc1429f703d590a2d456b97b74f0008b4a3ee;
  bytes32 internal constant _BORROWTARGETFACTORNUMERATOR_SLOT = 0xa65533f4b41f3786d877c8fdd4ae6d27ada84e1d9c62ea3aca309e9aa03af1cd;
  bytes32 internal constant _FOLD_SLOT = 0x1841be4c16015a744c9fbf595f7c6b32d40278c16c1fc7cf2de88c6348de44ba;

  uint256 public suppliedInUnderlying;
  uint256 public borrowedInUnderlying;
  address[] public liquidationPath;

  event Liquidated(
    uint256 amount
  );

  constructor() public BaseUpgradeableStrategy() {
    assert(_COLLATERALFACTORNUMERATOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.collateralFactorNumerator")) - 1));
    assert(_FACTORDENOMINATOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.factorDenominator")) - 1));
    assert(_BORROWTARGETFACTORNUMERATOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.borrowTargetFactorNumerator")) - 1));
    assert(_FOLD_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.fold")) - 1));
  }

  function initializeStrategy(
    address _storage,
    address _underlying,
    address _vtoken,
    address _vault,
    address _comptroller,
    address _xvs,
    uint256 _borrowTargetFactorNumerator,
    uint256 _collateralFactorNumerator,
    uint256 _factorDenominator,
    bool _fold
  )
  public initializer {
    BaseUpgradeableStrategy.initialize(
      _storage,
      _underlying,
      _vault,
      _comptroller,
      _xvs,
      80, // profit sharing numerator
      1000, // profit sharing denominator
      true, // sell
      1e16, // sell floor
      12 hours // implementation change delay
    );

    VenusInteractorInitializableV2.initialize(_underlying, _vtoken, _comptroller);

    require(IVault(_vault).underlying() == _underlying, "vault does not support underlying");
    _setFactorDenominator(_factorDenominator);
    _setCollateralFactorNumerator(_collateralFactorNumerator);
    setBorrowTargetFactorNumerator(_borrowTargetFactorNumerator);
    setFold(_fold);
  }

  modifier updateSupplyInTheEnd() {
    _;
    suppliedInUnderlying = CompleteVToken(vToken()).balanceOfUnderlying(address(this));
    borrowedInUnderlying = CompleteVToken(vToken()).borrowBalanceCurrent(address(this));
  }

  function depositArbCheck() public pure returns (bool) {
    // there's no arb here.
    return true;
  }

  function unsalvagableTokens(address token) public view returns (bool) {
    return (token == rewardToken() || token == underlying() || token == vToken());
  }

  /**
  * The strategy invests by supplying the underlying as a collateral.
  */
  function investAllUnderlying() public restricted updateSupplyInTheEnd {
    uint256 underlyingBalance = IBEP20(underlying()).balanceOf(address(this));
    if (underlyingBalance > 0) {
      _supply(underlyingBalance);
    }
    if (!fold()) {
      return;
    }
    uint256 supplied = CompleteVToken(vToken()).balanceOfUnderlying(address(this));
    uint256 borrowed = CompleteVToken(vToken()).borrowBalanceCurrent(address(this));
    uint256 balance = supplied.sub(borrowed);
    uint256 borrowTarget = balance.mul(borrowTargetFactorNumerator()).div(factorDenominator().sub(borrowTargetFactorNumerator()));
    while (borrowed < borrowTarget) {
      uint256 wantBorrow = borrowTarget.sub(borrowed);
      uint256 maxBorrow = supplied.mul(collateralFactorNumerator()).div(factorDenominator()).sub(borrowed);
      _borrow(MathUpgradeable.min(wantBorrow, maxBorrow));
      underlyingBalance = IBEP20(underlying()).balanceOf(address(this));
      if (underlyingBalance > 0) {
        _supply(underlyingBalance);
      }
      //update parameters
      supplied = CompleteVToken(vToken()).balanceOfUnderlying(address(this));
      borrowed = CompleteVToken(vToken()).borrowBalanceCurrent(address(this));
      balance = supplied.sub(borrowed);
    }
  }

  /**
  * Exits Venus and transfers everything to the vault.
  */
  function withdrawAllToVault() external restricted updateSupplyInTheEnd {
    withdrawMaximum();
    if (IBEP20(underlying()).balanceOf(address(this)) > 0) {
      IBEP20(underlying()).safeTransfer(vault(), IBEP20(underlying()).balanceOf(address(this)));
    }
  }

  function emergencyExit() external onlyGovernance updateSupplyInTheEnd {
    withdrawMaximum();
  }

  function withdrawMaximum() internal updateSupplyInTheEnd {
    if (sell()) {
      claimVenus();
      liquidateVenus();
    } else {
      emit ProfitNotClaimed();
    }
    redeemMaximum();
  }

  function withdrawToVault(uint256 amountUnderlying) external restricted updateSupplyInTheEnd {
    uint256 balance = IBEP20(underlying()).balanceOf(address(this));
    if (amountUnderlying <= balance) {
      IBEP20(underlying()).safeTransfer(vault(), amountUnderlying);
      return;
    }
    // get some of the underlying
    mustRedeemPartial(amountUnderlying);
    balance = IBEP20(underlying()).balanceOf(address(this));
    // transfer the amount requested (or the amount we have) back to vault()
    IBEP20(underlying()).safeTransfer(vault(), MathUpgradeable.min(amountUnderlying, balance));
    balance = IBEP20(underlying()).balanceOf(address(this));
    if (balance > 0) {
      // invest back to Venus
      investAllUnderlying();
    }
  }

  /**
  * Withdraws all assets, liquidates XVS, and invests again in the required ratio.
  */
  function doHardWork() public restricted {
    if (sell()) {
      liquidateVenus();
    } else {
      emit ProfitNotClaimed();
    }
    investAllUnderlying();
  }

  /**
  * Redeems maximum that can be redeemed from Venus.
  * Redeem the minimum of the underlying we own, and the underlying that the vToken can
  * immediately retrieve. Ensures that `redeemMaximum` doesn't fail silently.
  *
  * DOES NOT ensure that the strategy vUnderlying balance becomes 0.
  */
  function redeemMaximum() internal {
    redeemMaximumWithLoan(
      collateralFactorNumerator(),
      factorDenominator()
    );
  }

  /**
  * Redeems `amountUnderlying` or fails.
  */
  function mustRedeemPartial(uint256 amountUnderlying) internal {
    require(
      CompleteVToken(vToken()).getCash() >= amountUnderlying,
      "market cash cannot cover liquidity"
    );
    redeemPartialWithLoan(
      amountUnderlying,
      fold()? borrowTargetFactorNumerator():0,
      collateralFactorNumerator(),
      factorDenominator()
      );
    require(IBEP20(underlying()).balanceOf(address(this)) >= amountUnderlying.mul(999).div(1000), "Unable to withdraw the entire amountUnderlying");
  }

  /**
  * Salvages a token.
  */
  function salvage(address recipient, address token, uint256 amount) public onlyGovernance {
    // To make sure that governance cannot come in and take away the coins
    require(!unsalvagableTokens(token), "token is defined as not salvagable");
    IBEP20(token).safeTransfer(recipient, amount);
  }

  function liquidateVenus() internal {
    // Calculating rewardBalance is needed for the case underlying = reward token
    uint256 balance = IBEP20(rewardToken()).balanceOf(address(this));
    claimVenus();
    uint256 balanceAfter = IBEP20(rewardToken()).balanceOf(address(this));
    uint256 rewardBalance = balanceAfter.sub(balance);

    if (rewardBalance < sellFloor() || rewardBalance == 0) {
      emit TooLowBalance();
      return;
    }

    // give a profit share to fee forwarder, which re-distributes this to
    // the profit sharing pools
    notifyProfitInRewardToken(rewardBalance);

    balance = IBEP20(rewardToken()).balanceOf(address(this));

    emit Liquidated(balance);

    // no liquidation needed when underlying is reward token
    if (underlying() == rewardToken()) {
      return;
    }

    // we can accept 1 as minimum as this will be called by trusted roles only
    uint256 amountOutMin = 1;
    IBEP20(rewardToken()).safeApprove(address(pancakeswapRouterV2), 0);
    IBEP20(rewardToken()).safeApprove(address(pancakeswapRouterV2), balance);

    IPancakeRouter02(pancakeswapRouterV2).swapExactTokensForTokens(
      balance,
      amountOutMin,
      liquidationPath,
      address(this),
      block.timestamp
    );
  }

  /**
  * Returns the current balance. Ignores XVS that was not liquidated and invested.
  */
  function investedUnderlyingBalance() public view returns (uint256) {
    // underlying in this strategy + underlying redeemable from Venus + loan
    return IBEP20(underlying()).balanceOf(address(this))
    .add(suppliedInUnderlying)
    .sub(borrowedInUnderlying);
  }

  // updating collateral factor
  // note 1: one should settle the loan first before calling this
  // note 2: collateralFactorDenominator is 1000, therefore, for 20%, you need 200
  function _setCollateralFactorNumerator(uint256 _numerator) internal {
    require(_numerator < uint(600).mul(factorDenominator()).div(1000), "Collateral factor cannot be this high");
    setUint256(_COLLATERALFACTORNUMERATOR_SLOT, _numerator);
  }

  function collateralFactorNumerator() public view returns (uint256) {
    return getUint256(_COLLATERALFACTORNUMERATOR_SLOT);
  }

  function _setFactorDenominator(uint256 _denominator) internal {
    setUint256(_FACTORDENOMINATOR_SLOT, _denominator);
  }

  function factorDenominator() public view returns (uint256) {
    return getUint256(_FACTORDENOMINATOR_SLOT);
  }

  function setBorrowTargetFactorNumerator(uint256 _numerator) public onlyGovernance {
    require(_numerator < collateralFactorNumerator(), "Target should be lower than collateral limit");
    setUint256(_BORROWTARGETFACTORNUMERATOR_SLOT, _numerator);
  }

  function borrowTargetFactorNumerator() public view returns (uint256) {
    return getUint256(_BORROWTARGETFACTORNUMERATOR_SLOT);
  }

  function setFold (bool _fold) public onlyGovernance {
    setBoolean(_FOLD_SLOT, _fold);
  }

  function fold() public view returns (bool) {
    return getBoolean(_FOLD_SLOT);
  }

  function setSellFloor(uint256 floor) public onlyGovernance {
    _setSellFloor(floor);
  }

  function setSell(bool s) public onlyGovernance {
    _setSell(s);
  }

  function finalizeUpgrade() external onlyGovernance updateSupplyInTheEnd {
    _finalizeUpgrade();
  }
}
