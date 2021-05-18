//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./BeltSingleAssetStrategy.sol";

contract BeltSingleAssetStrategyMainnet_BeltBNB is BeltSingleAssetStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address beltBNB = address(0xa8Bb71facdd46445644C277F9499Dd22f6F0A30C);
    address masterBelt = address(0xD4BbC80b9B102b77B21A06cb77E954049605E6c1);
    BeltSingleAssetStrategy.initialize(
      _storage,
      beltBNB,
      _vault,
      masterBelt, // stakingPool
      belt,
      beltBNB,
      wbnb,
      9  // Pool id
    );
    pancake_route = [belt, wbnb];
  }
}
