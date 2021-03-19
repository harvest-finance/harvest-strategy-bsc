//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

import "hardhat/console.sol";

import "./inheritance/RewardTokenProfitNotifier.sol";
import "./interface/IStrategy.sol";

abstract contract StrategyBase is RewardTokenProfitNotifier  {

  event ProfitsNotCollected(address);
  event Liquidating(address, uint256);

  address public underlying;
  address public vault;
  mapping (address => bool) public unsalvagableTokens;
  address public pancakeRouterV2;

  modifier restricted() {
    require(msg.sender == vault || msg.sender == address(controller()) || msg.sender == address(governance()),
      "The sender has to be the controller or vault or governance");
    _;
  }

  constructor(
    address _storage,
    address _underlying,
    address _vault,
    address _rewardToken,
    address _pancakeswap
  ) RewardTokenProfitNotifier(_storage, _rewardToken) public {
    underlying = _underlying;
    vault = _vault;
    unsalvagableTokens[_rewardToken] = true;
    unsalvagableTokens[_underlying] = true;
    pancakeRouterV2 = _pancakeswap;
  }

}
