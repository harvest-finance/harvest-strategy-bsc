//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/snx-base/interfaces/SNXRewardInterface.sol";
import "../../base/snx-base/SNXRewardStrategy.sol";

contract BunnyStrategyMainnet_BUNNY is SNXRewardStrategy {

  address public wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
  address public bunny = address(0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51);
  address public bunnyRewardPool = address(0xCADc8CB26c8C7cB46500E61171b5F27e9bd7889D);
  address public constant pancakeRouter = address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);

  constructor(
    address _storage,
    address _vault
  )
  SNXRewardStrategy(_storage, bunny, _vault, wbnb, pancakeRouter)
  public {
    rewardPool = SNXRewardInterface(bunnyRewardPool);
    liquidationPath = [wbnb, bunny];
  }
}
