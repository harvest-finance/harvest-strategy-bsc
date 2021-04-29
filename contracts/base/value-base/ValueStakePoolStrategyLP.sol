// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import "./interface/IStakePool.sol";

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "../interface/IVault.sol";
import "../upgradability/BaseUpgradeableStrategy.sol";
import "../interface/valueswap/IValueLiquidPair.sol";
import "../interface/valueswap/IValueLiquidRouter.sol";

contract ValueStakePoolStrategyLP is BaseUpgradeableStrategy {
  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  address constant public valueLiquidRouter = address(0xb7e19a1188776f32E8C2B790D9ca578F2896Da7C);

  // additional storage slots (on top of BaseUpgradeableStrategy ones) are defined here
  bytes32 internal constant _POOLID_SLOT = 0x3fd729bfa2e28b7806b03a6e014729f59477b530f995be4d51defc9dad94810b;
  bytes32 internal constant _STRATEGY_REWARD_SLOT = 0x35166c03a1967bf3fd4d50261d81ac2201a316267c37c3e248442687303d0e51;

  // this would be reset on each upgrade
  mapping (address => address[]) public swapRoutes;
  address[] public stratReward2NotifyReward;

  constructor() public BaseUpgradeableStrategy() {
    assert(_POOLID_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.poolId")) - 1));
    assert(_STRATEGY_REWARD_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.strategyReward")) - 1));
  }

  function initializeStrategy(
    address _storage,
    address _underlying,
    address _vault,
    address _rewardPool,
    address _rewardToken,
    address _strategyReward,
    uint256 _poolID
  ) public initializer {

    BaseUpgradeableStrategy.initialize(
      _storage,
      _underlying,
      _vault,
      _rewardPool,
      _rewardToken,
      80, // profit sharing numerator
      1000, // profit sharing denominator
      true, // sell
      1e18, // sell floor
      12 hours // implementation change delay
    );

    address _lpt;
    _lpt = IStakePool(rewardPool()).stakeToken();
    require(_lpt == underlying(), "Staking token does not match underlying");
    _setPoolId(_poolID);

    address lpToken0 = IValueLiquidPair(underlying()).token0();
    address lpToken1 = IValueLiquidPair(underlying()).token1();

    // these would be required to be initialized separately by governance
    swapRoutes[lpToken0] = new address[](0);
    swapRoutes[lpToken1] = new address[](0);

    _setStrategyReward(_strategyReward);
  }

  function depositArbCheck() public pure returns(bool) {
    return true;
  }

  function rewardPoolBalance() internal view returns (uint256 bal) {
      (bal,,,,) = IStakePool(rewardPool()).getUserInfo(uint8(poolId()), address(this));
  }

  function unsalvagableTokens(address token) public view returns (bool) {
    return (token == rewardToken() || token == underlying());
  }

  function enterRewardPool() internal {
    uint256 entireBalance = IBEP20(underlying()).balanceOf(address(this));
    IBEP20(underlying()).safeApprove(rewardPool(), 0);
    IBEP20(underlying()).safeApprove(rewardPool(), entireBalance);

    IStakePool(rewardPool()).stake(entireBalance);
  }

  /*
  *   In case there are some issues discovered about the pool or underlying asset
  *   Governance can exit the pool properly
  *   The function is only used for emergency to exit the pool
  */
  function emergencyExit() public onlyGovernance {
    IStakePool(rewardPool()).emergencyWithdraw();
    _setPausedInvesting(true);
  }

  /*
  *   Resumes the ability to invest into the underlying reward pools
  */
  function continueInvesting() public onlyGovernance {
    _setPausedInvesting(false);
  }

  function setLiquidationPath(address _token, address [] memory _route) public onlyGovernance {
    require(_route[0] == rewardToken(), "Path should start with rewardToken");
    require(_route[_route.length-1] == _token, "Path should end with given Token");
    swapRoutes[_token] = _route;
  }

  // We assume that all the tradings can be done on Pancakeswap
  function _liquidateReward() internal {
    uint256 stratRewardBalance = IBEP20(strategyReward()).balanceOf(address(this));
    if (!sell() || stratRewardBalance < sellFloor() || stratRewardBalance == 0) {
      // Profits can be disabled for possible simplified and rapid exit
      emit ProfitsNotCollected(sell(), stratRewardBalance < sellFloor());
      return;
    }

    //swap vBSWAP to reward token on valueswap
    IBEP20(strategyReward()).safeApprove(valueLiquidRouter, 0);
    IBEP20(strategyReward()).safeApprove(valueLiquidRouter, stratRewardBalance);

    // we can accept 1 as minimum because this is called only by a trusted role
    uint256 amountOutMin = 1;
    IValueLiquidRouter(valueLiquidRouter).swapExactTokensForTokens(
      strategyReward(),
      rewardToken(),
      stratRewardBalance,
      amountOutMin,
      stratReward2NotifyReward,
      address(this),
      block.timestamp
    );
    uint256 rewardBalance = IBEP20(rewardToken()).balanceOf(address(this));

    notifyProfitInRewardToken(rewardBalance);
    uint256 remainingRewardBalance = IBEP20(rewardToken()).balanceOf(address(this));

    if (remainingRewardBalance == 0) {
      return;
    }

    // allow Pancakeswap to sell our reward
    IBEP20(rewardToken()).safeApprove(valueLiquidRouter, 0);
    IBEP20(rewardToken()).safeApprove(valueLiquidRouter, remainingRewardBalance);

    address lpToken0 = IValueLiquidPair(underlying()).token0();
    address lpToken1 = IValueLiquidPair(underlying()).token1();
    (uint32 tokenWeight0,) = IValueLiquidPair(underlying()).getTokenWeights();

    uint256 toToken0 = remainingRewardBalance.mul(tokenWeight0).div(100);
    uint256 toToken1 = remainingRewardBalance.sub(toToken0);

    uint256 token0Amount;

    if (swapRoutes[lpToken0].length > 0) {
      // if we need to liquidate the token0
      IValueLiquidRouter(valueLiquidRouter).swapExactTokensForTokens(
        rewardToken(),
        lpToken0,
        toToken0,
        amountOutMin,
        swapRoutes[lpToken0],
        address(this),
        block.timestamp
      );
      token0Amount = IBEP20(lpToken0).balanceOf(address(this));
    } else {
      // otherwise we assme token0 is the reward token itself
      token0Amount = toToken0;
    }

    uint256 token1Amount;

    if (swapRoutes[lpToken1].length > 0) {
      // sell reward token to token1
      IValueLiquidRouter(valueLiquidRouter).swapExactTokensForTokens(
        rewardToken(),
        lpToken1,
        toToken1,
        amountOutMin,
        swapRoutes[lpToken1],
        address(this),
        block.timestamp
      );
      token1Amount = IBEP20(lpToken1).balanceOf(address(this));
    } else {
      token1Amount = toToken1;
    }

    // provide token1 and token2 to Pancake
    IBEP20(lpToken0).safeApprove(valueLiquidRouter, 0);
    IBEP20(lpToken0).safeApprove(valueLiquidRouter, token0Amount);

    IBEP20(lpToken1).safeApprove(valueLiquidRouter, 0);
    IBEP20(lpToken1).safeApprove(valueLiquidRouter, token1Amount);

    // we provide liquidity to Pancake
    uint256 liquidity;
    (,,liquidity) = IValueLiquidRouter(valueLiquidRouter).addLiquidity(
      underlying(),
      lpToken0,
      lpToken1,
      token0Amount,
      token1Amount,
      1,  // we are willing to take whatever the pair gives us
      1,  // we are willing to take whatever the pair gives us
      address(this),
      block.timestamp
    );
  }

  /*
  *   Stakes everything the strategy holds into the reward pool
  */
  function investAllUnderlying() internal onlyNotPausedInvesting {
    // this check is needed, because most of the SNX reward pools will revert if
    // you try to stake(0).
    if(IBEP20(underlying()).balanceOf(address(this)) > 0) {
      enterRewardPool();
    }
  }

  /*
  *   Withdraws all the asset to the vault
  */
  function withdrawAllToVault() public restricted {
    if (address(rewardPool()) != address(0)) {
      IStakePool(rewardPool()).exit();
    }
    _liquidateReward();
    IBEP20(underlying()).safeTransfer(vault(), IBEP20(underlying()).balanceOf(address(this)));
  }

  /*
  *   Withdraws all the asset to the vault
  */
  function withdrawToVault(uint256 amount) public restricted {
    // Typically there wouldn't be any amount here
    // however, it is possible because of the emergencyExit
    uint256 entireBalance = IBEP20(underlying()).balanceOf(address(this));

    if(amount > entireBalance){
      // While we have the check above, we still using SafeMath below
      // for the peace of mind (in case something gets changed in between)
      uint256 needToWithdraw = amount.sub(entireBalance);
      uint256 toWithdraw = MathUpgradeable.min(rewardPoolBalance(), needToWithdraw);
      IStakePool(rewardPool()).withdraw(toWithdraw);
    }

    IBEP20(underlying()).safeTransfer(vault(), amount);
  }

  /*
  *   Note that we currently do not have a mechanism here to include the
  *   amount of reward that is accrued.
  */
  function investedUnderlyingBalance() external view returns (uint256) {
    if (rewardPool() == address(0)) {
      return IBEP20(underlying()).balanceOf(address(this));
    }
    // Adding the amount locked in the reward pool and the amount that is somehow in this contract
    // both are in the units of "underlying"
    // The second part is needed because there is the emergency exit mechanism
    // which would break the assumption that all the funds are always inside of the reward pool
    return rewardPoolBalance().add(IBEP20(underlying()).balanceOf(address(this)));
  }

  /*
  *   Governance or Controller can claim coins that are somehow transferred into the contract
  *   Note that they cannot come in take away coins that are used and defined in the strategy itself
  */
  function salvage(address recipient, address token, uint256 amount) external onlyControllerOrGovernance {
     // To make sure that governance cannot come in and take away the coins
    require(!unsalvagableTokens(token), "token is defined as not salvagable");
    IBEP20(token).safeTransfer(recipient, amount);
  }

  /*
  *   Get the reward, sell it in exchange for underlying, invest what you got.
  *   It's not much, but it's honest work.
  *
  *   Note that although `onlyNotPausedInvesting` is not added here,
  *   calling `investAllUnderlying()` affectively blocks the usage of `doHardWork`
  *   when the investing is being paused by governance.
  */
  function doHardWork() external onlyNotPausedInvesting restricted {
    uint256 bal = rewardPoolBalance();
    if (bal != 0) {
      IStakePool(rewardPool()).claimReward();
      _liquidateReward();
    }
    investAllUnderlying();
  }

  /**
  * Can completely disable claiming rewards and selling. Good for emergency withdraw in the
  * simplest possible way.
  */
  function setSell(bool s) public onlyGovernance {
    _setSell(s);
  }

  /**
  * Sets the minimum amount needed to trigger a sale.
  */
  function setSellFloor(uint256 floor) public onlyGovernance {
    _setSellFloor(floor);
  }

  // masterchef rewards pool ID
  function _setPoolId(uint256 _value) internal {
    setUint256(_POOLID_SLOT, _value);
  }

  function poolId() public view returns (uint256) {
    return getUint256(_POOLID_SLOT);
  }

  function _setStrategyReward(address _address) internal {
    setAddress(_STRATEGY_REWARD_SLOT, _address);
  }

  function strategyReward() public view returns (address) {
    return getAddress(_STRATEGY_REWARD_SLOT);
  }

  function finalizeUpgrade() external onlyGovernance {
    _finalizeUpgrade();
    // reset the liquidation paths
    // they need to be re-set manually
    swapRoutes[IValueLiquidPair(underlying()).token0()] = new address[](0);
    swapRoutes[IValueLiquidPair(underlying()).token1()] = new address[](0);
  }
}
