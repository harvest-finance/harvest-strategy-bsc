//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./BeltSingleAssetStrategy.sol";

contract BeltSingleAssetStrategyMainnet_BeltETH is BeltSingleAssetStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address beltETH = address(0xAA20E8Cb61299df2357561C2AC2e1172bC68bc25);
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address masterBelt = address(0xD4BbC80b9B102b77B21A06cb77E954049605E6c1);
    BeltSingleAssetStrategy.initialize(
      _storage,
      beltETH,
      _vault,
      masterBelt, // stakingPool
      belt,
      beltETH,
      eth,
      8  // Pool id
    );
    pancake_route = [belt, wbnb, eth];
  }
}
