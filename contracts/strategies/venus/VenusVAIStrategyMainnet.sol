//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "../../base/venus-base/interface/IVAIVault.sol";
import "../../base/upgradability/BaseUpgradeableStrategy.sol";
import "../../base/interface/pancakeswap/IPancakeRouter02.sol";

contract VenusVAIStrategyMainnet is BaseUpgradeableStrategy {

  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  address constant public pancakeRouterV2 = address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
  address[] public liquidationPath;

  constructor() public BaseUpgradeableStrategy() {
  }

  function initializeStrategy(
    address _storage,
    address _vault
  )
  public initializer {
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address vai = address(0x4BD17003473389A42DAF6a0a729f6Fdb328BbBd7);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);

    BaseUpgradeableStrategy.initialize(
      _storage,
      vai,
      _vault,
      address(0x0667Eed0a0aAb930af74a3dfeDD263A73994f216), //RewardPool
      venus,
      80, // profit sharing numerator
      1000, // profit sharing denominator
      true, // sell
      1e16, // sell floor
      12 hours // implementation change delay
    );

    liquidationPath = [venus, wbnb, busd, vai];
  }

  function depositArbCheck() public pure returns(bool) {
    return true;
  }

  function unsalvagableTokens(address token) public view returns (bool) {
    return (token == rewardToken() || token == underlying());
  }

  /*
  *   In case there are some issues discovered about the pool or underlying asset
  *   Governance can exit the pool properly
  *   The function is only used for emergency to exit the pool
  */
  function emergencyExit() public onlyGovernance {
    (uint256 amountInvested,) = IVAIVault(rewardPool()).userInfo(address(this));
    IVAIVault(rewardPool()).withdraw(amountInvested);
    _setPausedInvesting(true);
  }

  /*
  *   Resumes the ability to invest into the underlying reward pools
  */
  function continueInvesting() public onlyGovernance {
    _setPausedInvesting(false);
  }

  /**
  * Sets the route for liquidating the reward token to the underlying token
  */
  function setLiquidationPath(address[] memory _newPath) public onlyGovernance {
    liquidationPath = _newPath;
  }

  // We assume that all the tradings can be done on Pancakeswap
  function _liquidateReward() internal {
    uint256 rewardAmount = IBEP20(rewardToken()).balanceOf(address(this));

    if (rewardAmount > 0 // we have tokens to swap
      && liquidationPath.length > 1 // and we have a route to do the swap
    ) {
      notifyProfitInRewardToken(rewardAmount);
      rewardAmount = IBEP20(rewardToken()).balanceOf(address(this));

      // we can accept 1 as minimum because this is called only by a trusted role
      uint256 amountOutMin = 1;

      IBEP20(rewardToken()).safeApprove(pancakeRouterV2, 0);
      IBEP20(rewardToken()).safeApprove(pancakeRouterV2, rewardAmount);

      IPancakeRouter02(pancakeRouterV2).swapExactTokensForTokens(
        rewardAmount,
        amountOutMin,
        liquidationPath,
        address(this),
        block.timestamp
      );
    }
  }

  /*
  *   Stakes everything the strategy holds into the reward pool
  */
  function investAllUnderlying() internal onlyNotPausedInvesting {
    // this check is needed, because most of the SNX reward pools will revert if
    // you try to stake(0).
    uint256 underlyingBalance = IBEP20(underlying()).balanceOf(address(this));
    if(underlyingBalance > 0) {
      IBEP20(underlying()).safeApprove(rewardPool(), 0);
      IBEP20(underlying()).safeApprove(rewardPool(), underlyingBalance);
      IVAIVault(rewardPool()).deposit(underlyingBalance);
    }
  }

  /*
  *   Withdraws all the asset to the vault
  */
  function withdrawAllToVault() public restricted {
    if (rewardPool() != address(0)) {
      (uint256 amountInvested,) = IVAIVault(rewardPool()).userInfo(address(this));
      if (amountInvested > 0) {
        IVAIVault(rewardPool()).withdraw(amountInvested);
      }
    }
    _liquidateReward();
    if (IBEP20(underlying()).balanceOf(address(this)) > 0) {
      IBEP20(underlying()).safeTransfer(vault(), IBEP20(underlying()).balanceOf(address(this)));
    }
  }

  /*
  *   Withdraws a set amount to the vault
  */
  function withdrawToVault(uint256 amount) external restricted {
    // Typically there wouldn't be any amount here
    // however, it is possible because of the emergencyExit
    uint256 underlyingBalance = IBEP20(underlying()).balanceOf(address(this));
    if(amount > underlyingBalance){
      // While we have the check above, we still using SafeMath below
      // for the peace of mind (in case something gets changed in between)
      uint256 needToWithdraw = amount.sub(underlyingBalance);
      (uint256 amountInvested,) = IVAIVault(rewardPool()).userInfo(address(this));
      IVAIVault(rewardPool()).withdraw(MathUpgradeable.min(amountInvested, needToWithdraw));
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
    (uint256 amountInvested,) = IVAIVault(rewardPool()).userInfo(address(this));
    return amountInvested.add(IBEP20(underlying()).balanceOf(address(this)));
  }

  /*
  *   Governance or Controller can claim coins that are somehow transferred into the contract
  *   Note that they cannot come in take away coins that are used and defined in the strategy itself
  *   Those are protected by the "unsalvagableTokens". To check, see where those are being flagged.
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
    IVAIVault(rewardPool()).updatePendingRewards();
    IVAIVault(rewardPool()).claim();
    _liquidateReward();
    investAllUnderlying();
  }

  /**
  * Sets the minimum amount of CRV needed to trigger a sale.
  */
  function setSellFloor(uint256 floor) public onlyGovernance {
    _setSellFloor(floor);
  }

  function finalizeUpgrade() external onlyGovernance {
    _finalizeUpgrade();
    // reset the liquidation paths
    // they need to be re-set manually
    liquidationPath = new address[](0);
  }
}
