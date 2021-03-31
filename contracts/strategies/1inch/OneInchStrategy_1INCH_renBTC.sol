pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/utils/Address.sol";
import "./interface/IMooniswap.sol";
import "./interface/IFarmingRewardsV2.sol";

import "../../base/venus-base/wbnb/WBNB.sol";

import "../../base/interface/pancakeswap/IPancakeRouter02.sol";
import "../../base/interface/IVault.sol";

import "../../base/StrategyBase.sol";

/**
* This strategy is for 1INCH / X 1inch LP tokens
* 1INCH must be token0, and the other token is denoted X
*/
contract OneInchStrategy_1INCH_renBTC is StrategyBase {

  using SafeBEP20 for IBEP20;
  using Address for address;
  using SafeMath for uint256;

  event Liquidating(address token, uint256 amount);
  event ProfitsNotCollected(address token);

  address public pool;
  address public oneInchBNBLP;
  address public oneInch = address(0x111111111117dC0aa78b770fA6A738034120C302);
  address public renBTC = address(0xfCe146bF3146100cfe5dB4129cf6C82b0eF4Ad8c);
  address public _wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

  uint256 maxUint = uint256(~0);
  address public oneInchEthLP;

  // token0 is ONEINCH
  address public token1;

  uint256 slippageNumerator = 9;
  uint256 slippageDenominator = 10;

  // a flag for disabling selling for simplified emergency exit
  bool public sell = true;
  // minimum 1inch amount to be liquidation
  uint256 public sellFloorOneInch = 1e17;

  constructor(
    address _storage,
    address _vault,
    address _underlying,
    address _pool,
    address _oneInchBNBLP
  )
  StrategyBase(_storage, _underlying, _vault, _wbnb, address(0)) public {
    require(IVault(_vault).underlying() == _underlying, "vault does not support the required LP token");
    token1 = IMooniswap(_underlying).token1();
    pool = _pool;
    require(token1 != address(0), "token1 must be non-zero");
    require(IMooniswap(_underlying).token0() == oneInch, "token0 must be 1INCH");

    oneInchBNBLP = _oneInchBNBLP;

    // making 1inch reward token salvagable to be able to
    // liquidate externally
    unsalvagableTokens[oneInch] = false;
    unsalvagableTokens[token1] = true;
  }

  function depositArbCheck() public view returns(bool) {
    return true;
  }

  /**
  * Salvages a token. We should not be able to salvage underlying.
  */
  function salvage(address recipient, address token, uint256 amount) public onlyGovernance {
    // To make sure that governance cannot come in and take away the coins
    require(!unsalvagableTokens[token], "token is defined as not salvageable");
    IBEP20(token).safeTransfer(recipient, amount);
  }

  /**
  * Withdraws underlying from the investment pool that mints crops.
  */
  function withdrawUnderlyingFromPool(uint256 amount) internal {
    IFarmingRewardsV2(pool).withdraw(
      MathUpgradeable.min(IFarmingRewardsV2(pool).balanceOf(address(this)), amount)
    );
  }

  /**
  * Withdraws the underlying tokens to the pool in the specified amount.
  */
  function withdrawToVault(uint256 amountUnderlying) external restricted {
    withdrawUnderlyingFromPool(amountUnderlying);
    require(IBEP20(underlying).balanceOf(address(this)) >= amountUnderlying, "insufficient balance for the withdrawal");
    IBEP20(underlying).safeTransfer(vault, amountUnderlying);
  }

  /**
  * Withdraws all the underlying tokens to the pool.
  */
  function withdrawAllToVault() external restricted {
    claimAndLiquidate();
    uint256 bal = IFarmingRewardsV2(pool).balanceOf(address(this));
    if (bal != 0) {
      withdrawUnderlyingFromPool(maxUint);
    }
    uint256 balance = IBEP20(underlying).balanceOf(address(this));
    IBEP20(underlying).safeTransfer(vault, balance);
  }

  /**
  * Invests all the underlying into the pool that mints crops (1inch)
  */
  function investAllUnderlying() public restricted {
    uint256 underlyingBalance = IBEP20(underlying).balanceOf(address(this));
    if (underlyingBalance > 0) {
      IBEP20(underlying).safeApprove(pool, 0);
      IBEP20(underlying).safeApprove(pool, underlyingBalance);
      IFarmingRewardsV2(pool).stake(underlyingBalance);
    }
  }

  /**
  * Claims the 1Inch crop, converts it accordingly
  */

  function claimAndLiquidate() internal {
    if (!sell) {
      // Profits can be disabled for possible simplified and rapid exit
      emit ProfitsNotCollected(oneInch);
      return;
    }
    IFarmingRewardsV2(pool).getAllRewards();
    uint256 oneInchBalance = IBEP20(oneInch).balanceOf(address(this));
    uint256 renBTCBalance = IBEP20(renBTC).balanceOf(address(this));
    // swap renBTC to 1INCH to notify rewards in 1INCH
    uint256 amountOutMin = 1;
    if (renBTCBalance != 0) {
      IBEP20(renBTC).safeApprove(underlying, 0);
      IBEP20(renBTC).safeApprove(underlying, renBTCBalance);

      // with the remaining, half would be converted into the second token
      IMooniswap(underlying).swap(renBTC, oneInch, renBTCBalance, amountOutMin, address(0));
    }

    oneInchBalance = IBEP20(oneInch).balanceOf(address(this));
    if (oneInchBalance < sellFloorOneInch || oneInchBalance == 0) {
      emit ProfitsNotCollected(oneInch);
      return;
    }

    // convert 1INCH to wBNB to notify
    IBEP20(oneInch).safeApprove(oneInchBNBLP, 0);
    IBEP20(oneInch).safeApprove(oneInchBNBLP, oneInchBalance);

    // with the remaining, half would be converted into the second token
    IMooniswap(oneInchBNBLP).swap(oneInch, address(0), oneInchBalance, amountOutMin, address(0));

    uint256 bnbBalance = address(this).balance;
    WBNB wbnb = WBNB(payable(_wbnb));
    wbnb.deposit.value(bnbBalance)();

    // share 30% of the 1INCH as a profit sharing reward
    notifyProfitInRewardToken(bnbBalance);

    //swap all wBNB back to 1Inch
    uint256 remainingBalance = IBEP20(_wbnb).balanceOf(address(this));

    wbnb.withdraw(remainingBalance);
    IMooniswap(oneInchBNBLP).swap.value(remainingBalance)(
      address(0),
      oneInch,
      remainingBalance,
      amountOutMin,
      address(0)
      );

    uint256 remainingOneInchBalance = IBEP20(oneInch).balanceOf(address(this));

    IBEP20(oneInch).safeApprove(underlying, 0);
    IBEP20(oneInch).safeApprove(underlying, remainingOneInchBalance.div(2));

    // with the remaining, half would be converted into the second token
    IMooniswap(underlying).swap(oneInch, token1, remainingOneInchBalance.div(2), amountOutMin, address(0));

    uint256 oneInchAmount = IBEP20(oneInch).balanceOf(address(this));
    uint256 token1Amount = IBEP20(token1).balanceOf(address(this));

    IBEP20(oneInch).safeApprove(underlying, 0);
    IBEP20(oneInch).safeApprove(underlying, oneInchAmount);
    IBEP20(token1).safeApprove(underlying, 0);
    IBEP20(token1).safeApprove(underlying, token1Amount);

    // adding liquidity: ETH + token1
    IMooniswap(underlying).deposit(
      [oneInchAmount, token1Amount],
      [oneInchAmount.mul(slippageNumerator).div(slippageDenominator),
        token1Amount.mul(slippageNumerator).div(slippageDenominator)
      ]
    );
  }

  /**
  * Claims and liquidates 1inch into underlying, and then invests all underlying.
  */
  function doHardWork() public restricted {
    claimAndLiquidate();
    investAllUnderlying();
  }

  /**
  * Investing all underlying.
  */
  function investedUnderlyingBalance() public view returns (uint256) {
    return IFarmingRewardsV2(pool).balanceOf(address(this)).add(
      IBEP20(underlying).balanceOf(address(this))
    );
  }

  /**
  * Can completely disable claiming 1inch rewards and selling. Good for emergency withdraw in the
  * simplest possible way.
  */
  function setSell(bool s) public onlyGovernance {
    sell = s;
  }

  /**
  * Sets the minimum amount of 1inch needed to trigger a sale.
  */
  function setSellFloorAndSlippages(uint256 _sellFloorOneInch, uint256 _slippageNumerator, uint256 _slippageDenominator) public onlyGovernance {
    sellFloorOneInch = _sellFloorOneInch;
    slippageNumerator = _slippageNumerator;
    slippageDenominator = _slippageDenominator;
  }

  receive() external payable {}
}
