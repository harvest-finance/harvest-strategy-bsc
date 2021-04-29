//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueStakePoolStrategyLP.sol";

contract IronStrategyMainnet_STEEL_BNB is ValueStakePoolStrategyLP {

  address public steel_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xed2d6e9E400705f41C24dDa2e088ADbfD47C5818);
    address steel = address(0x9001eE054F1692feF3A48330cB543b6FEc6287eb);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    ValueStakePoolStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x8a82b731a33657211387058B55ccB23eb69De693), // master chef contract
      wbnb,
      steel,
      0  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    stratReward2NotifyReward = [underlying];
    swapRoutes[steel] = [underlying];
  }
}
