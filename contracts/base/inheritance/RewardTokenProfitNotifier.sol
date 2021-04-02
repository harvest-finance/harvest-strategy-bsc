//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "../interface/IController.sol";
import "./Controllable.sol";

contract RewardTokenProfitNotifier is Controllable {
  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;

  uint256 public profitSharingNumerator;
  uint256 public profitSharingDenominator;
  address public rewardToken;

  constructor(
    address _storage,
    address _rewardToken
  ) public Controllable(_storage){
    rewardToken = _rewardToken;
    // persist in the state for immutability of the fee
    profitSharingNumerator = 80; //IController(controller()).profitSharingNumerator();
    profitSharingDenominator = 1000; //IController(controller()).profitSharingDenominator();
    require(profitSharingNumerator < profitSharingDenominator, "invalid profit share");
  }

  event ProfitLogInReward(uint256 profitAmount, uint256 feeAmount, uint256 timestamp);

  function notifyProfitInRewardToken(uint256 _rewardBalance) internal {
    if( _rewardBalance > 0 ){
      uint256 feeAmount = _rewardBalance.mul(profitSharingNumerator).div(profitSharingDenominator);
      emit ProfitLogInReward(_rewardBalance, feeAmount, block.timestamp);
      IBEP20(rewardToken).safeApprove(controller(), 0);
      IBEP20(rewardToken).safeApprove(controller(), feeAmount);

      IController(controller()).notifyFee(
        rewardToken,
        feeAmount
      );
    } else {
      emit ProfitLogInReward(0, 0, block.timestamp);
    }
  }

}
