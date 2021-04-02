//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/utils/Address.sol";
import "./interface/IMooniswap.sol";
import "./interface/IFarmingRewards.sol";

import "../../base/venus-base/wbnb/WBNB.sol";

import "../../base/interface/pancakeswap/IPancakeRouter02.sol";
import "../../base/interface/IVault.sol";

import "../../base/StrategyBase.sol";

/**
* This strategy is for 1INCH / BNB 1inch LP tokens
* 1INCH must be token0, and the other token is BNB
*/
contract OneInchStrategy_1INCH_BNB is StrategyBase {

  using SafeBEP20 for IBEP20;
  using Address for address;
  using SafeMath for uint256;

  event Liquidating(address token, uint256 amount);
  event ProfitsNotCollected(address token);

  address public pool;
  address public oneInch = address(0x111111111117dC0aa78b770fA6A738034120C302);
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
    address _pool
  )
  StrategyBase(_storage, _underlying, _vault, _wbnb, address(0)) public {
    require(IVault(_vault).underlying() == _underlying, "vault does not support the required LP token");
    token1 = IMooniswap(_underlying).token1();
    pool = _pool;
    require(IMooniswap(_underlying).token1() == oneInch, "token1 must be 1INCH");

    // making 1inch reward token salvagable to be able to
    // liquidate externally
    unsalvagableTokens[oneInch] = false;
  }

  function depositArbCheck() public pure returns(bool) {
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
    IFarmingRewards(pool).withdraw(
      MathUpgradeable.min(IFarmingRewards(pool).balanceOf(address(this)), amount)
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
    uint256 bal = IFarmingRewards(pool).balanceOf(address(this));
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
      IFarmingRewards(pool).stake(underlyingBalance);
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
    IFarmingRewards(pool).getReward();
    uint256 oneInchBalance = IBEP20(oneInch).balanceOf(address(this));
    if (oneInchBalance < sellFloorOneInch || oneInchBalance == 0) {
      emit ProfitsNotCollected(oneInch);
      return;
    }

    // convert 1INCH to wBNB to notify
    IBEP20(oneInch).safeApprove(underlying, 0);
    IBEP20(oneInch).safeApprove(underlying, oneInchBalance);

    // with the remaining, half would be converted into the second token
    uint256 amountOutMin = 1;
    IMooniswap(underlying).swap(oneInch, address(0), oneInchBalance, amountOutMin, address(0));

    uint256 bnbBalance = address(this).balance;
    WBNB wbnb = WBNB(payable(_wbnb));
    wbnb.deposit{value: bnbBalance}();

    // share 30% of the 1INCH as a profit sharing reward
    notifyProfitInRewardToken(bnbBalance);

    uint256 remainingBalance = IBEP20(_wbnb).balanceOf(address(this));

    wbnb.withdraw(remainingBalance);
    IMooniswap(underlying).swap{value: remainingBalance.div(2)}(
      address(0),
      oneInch,
      remainingBalance.div(2),
      amountOutMin,
      address(0)
      );

    uint256 oneInchAmount = IBEP20(oneInch).balanceOf(address(this));
    uint256 bnbAmount = address(this).balance;

    IBEP20(oneInch).safeApprove(underlying, 0);
    IBEP20(oneInch).safeApprove(underlying, oneInchAmount);

    // adding liquidity: ETH + token1
    IMooniswap(underlying).deposit{value: bnbAmount}(
      [bnbAmount, oneInchAmount],
      [bnbAmount.mul(slippageNumerator).div(slippageDenominator),
        oneInchAmount.mul(slippageNumerator).div(slippageDenominator)
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
    return IFarmingRewards(pool).balanceOf(address(this)).add(
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
