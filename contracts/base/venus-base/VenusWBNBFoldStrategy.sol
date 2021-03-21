// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "./VenusInteractorInitializable.sol";
import "../upgradability/BaseUpgradeableStrategy.sol";
import "../interface/IVault.sol";
import "../interface/pancakeswap/IPancakeRouter02.sol";

contract VenusWBNBFoldStrategy is BaseUpgradeableStrategy, VenusInteractorInitializable {

  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  event ProfitNotClaimed();
  event TooLowBalance();

  IBEP20 public xvs;

  address public pancakeswapRouterV2;
  uint256 public suppliedInUnderlying;
  uint256 public borrowedInUnderlying;
  bool public allowEmergencyLiquidityShortage = false;
  uint256 public collateralFactorNumerator;
  uint256 public collateralFactorDenominator;
  uint256 public folds;
  address[] public liquidationPath;

  uint256 public borrowMinThreshold = 0;

  // These tokens cannot be claimed by the controller
  mapping(address => bool) public unsalvagableTokens;

  event Liquidated(
    uint256 amount
  );

  constructor() public BaseUpgradeableStrategy() {
  }

  function initializeStrategy(
    address _storage,
    address _underlying,
    address _vtoken,
    address _vault,
    address _comptroller,
    address _xvs,
    address _pancakeswap,
    uint256 _collateralFactorNumerator,
    uint256 _collateralFactorDenominator,
    uint256 _folds
  )
  public initializer {
    BaseUpgradeableStrategy.initialize(
      _storage,
      _underlying,
      _vault,
      _comptroller,
      _xvs,
      300, // profit sharing numerator
      1000, // profit sharing denominator
      true, // sell
      1e16, // sell floor
      12 hours // implementation change delay
    );

    VenusInteractorInitializable.initialize(_underlying, _vtoken, _comptroller);

    require(IVault(_vault).underlying() == _underlying, "vault does not support underlying");
    comptroller = ComptrollerInterface(_comptroller);
    xvs = IBEP20(_xvs);
    vtoken = CompleteVToken(_vtoken);
    pancakeswapRouterV2 = _pancakeswap;
    collateralFactorNumerator = _collateralFactorNumerator;
    collateralFactorDenominator = _collateralFactorDenominator;
    folds = _folds;

    // set these tokens to be not salvagable
    unsalvagableTokens[_underlying] = true;
    unsalvagableTokens[_vtoken] = true;
    unsalvagableTokens[_xvs] = true;
  }

  modifier updateSupplyInTheEnd() {
    _;
    suppliedInUnderlying = vtoken.balanceOfUnderlying(address(this));
    borrowedInUnderlying = vtoken.borrowBalanceCurrent(address(this));
  }

  function depositArbCheck() public view returns (bool) {
    // there's no arb here.
    return true;
  }

  /**
  * The strategy invests by supplying the underlying as a collateral.
  */
  function investAllUnderlying() public restricted updateSupplyInTheEnd {
    uint256 balance = IBEP20(underlying()).balanceOf(address(this));
    _supplyBNBInWBNB(balance);
    for (uint256 i = 0; i < folds; i++) {
      uint256 borrowAmount = balance.mul(collateralFactorNumerator).div(collateralFactorDenominator);
      _borrowInWBNB(borrowAmount);
      balance = IBEP20(underlying()).balanceOf(address(this));
      _supplyBNBInWBNB(balance);
    }
  }

  /**
  * Exits Venus and transfers everything to the vault.
  */
  function withdrawAllToVault() external restricted updateSupplyInTheEnd {
    if (allowEmergencyLiquidityShortage) {
      withdrawMaximum();
    } else {
      withdrawAllWeInvested();
    }
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

  function withdrawAllWeInvested() internal updateSupplyInTheEnd {
    if (sell()) {
      claimVenus();
      liquidateVenus();
    } else {
      emit ProfitNotClaimed();
    }
    uint256 _currentSuppliedBalance = vtoken.balanceOfUnderlying(address(this));
    uint256 _currentBorrowedBalance = vtoken.borrowBalanceCurrent(address(this));

    mustRedeemPartial(_currentSuppliedBalance.sub(_currentBorrowedBalance));
  }

  function withdrawToVault(uint256 amountUnderlying) external restricted updateSupplyInTheEnd {
    if (amountUnderlying <= IBEP20(underlying()).balanceOf(address(this))) {
      IBEP20(underlying()).safeTransfer(vault(), amountUnderlying);
      return;
    }

    // get some of the underlying
    mustRedeemPartial(amountUnderlying);

    // transfer the amount requested (or the amount we have) back to vault
    IBEP20(underlying()).safeTransfer(vault(), amountUnderlying);

    // invest back to compound
    investAllUnderlying();
  }

  /**
  * Withdraws all assets, liquidates XVS, and invests again in the required ratio.
  */
  function doHardWork() public restricted {
    if (sell()) {
      claimVenus();
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
  * DOES NOT ensure that the strategy cUnderlying balance becomes 0.
  */
  function redeemMaximum() internal {
    redeemMaximumWBNBWithLoan(
      collateralFactorNumerator,
      collateralFactorDenominator,
      borrowMinThreshold
    );
  }

  /**
  * Redeems `amountUnderlying` or fails.
  */
  function mustRedeemPartial(uint256 amountUnderlying) internal {
    require(
      vtoken.getCash() >= amountUnderlying,
      "market cash cannot cover liquidity"
    );
    redeemMaximum();
    require(IBEP20(underlying()).balanceOf(address(this)) >= amountUnderlying, "Unable to withdraw the entire amountUnderlying");
  }

  /**
  * Salvages a token.
  */
  function salvage(address recipient, address token, uint256 amount) public onlyGovernance {
    // To make sure that governance cannot come in and take away the coins
    require(!unsalvagableTokens[token], "token is defined as not salvagable");
    IBEP20(token).safeTransfer(recipient, amount);
  }

  function liquidateVenus() internal {
    uint256 balance = xvs.balanceOf(address(this));
    if (balance < sellFloor() || balance == 0) {
      emit TooLowBalance();
      return;
    }

    // give a profit share to fee forwarder, which re-distributes this to
    // the profit sharing pools
    notifyProfitInRewardToken(balance);

    balance = xvs.balanceOf(address(this));

    emit Liquidated(balance);
    // we can accept 1 as minimum as this will be called by trusted roles only
    uint256 amountOutMin = 1;
    IBEP20(address(xvs)).safeApprove(address(pancakeswapRouterV2), 0);
    IBEP20(address(xvs)).safeApprove(address(pancakeswapRouterV2), balance);

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

  function setAllowLiquidityShortage(bool allowed) external restricted {
    allowEmergencyLiquidityShortage = allowed;
  }

  function setBorrowMinThreshold(uint256 threshold) public onlyGovernance {
    borrowMinThreshold = threshold;
  }

  // updating collateral factor
  // note 1: one should settle the loan first before calling this
  // note 2: collateralFactorDenominator is 1000, therefore, for 20%, you need 200
  function setCollateralFactorNumerator(uint256 numerator) public onlyGovernance {
    require(numerator <= 740, "Collateral factor cannot be this high");
    collateralFactorNumerator = numerator;
  }

  function setFolds(uint256 _folds) public onlyGovernance {
    folds = _folds;
  }

  function setSellFloor(uint256 floor) public onlyGovernance {
    _setSellFloor(floor);
  }

  function setSell(bool s) public onlyGovernance {
    _setSell(s);
  }
}
