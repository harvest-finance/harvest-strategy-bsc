//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./BeltSingleAssetStrategy.sol";

contract BeltSingleAssetStrategyMainnet_BeltBTCB is BeltSingleAssetStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address beltBTC = address(0x51bd63F240fB13870550423D208452cA87c44444);
    address btcb = address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    address masterBelt = address(0xD4BbC80b9B102b77B21A06cb77E954049605E6c1);
    BeltSingleAssetStrategy.initialize(
      _storage,
      beltBTC,
      _vault,
      masterBelt, // stakingPool
      belt,
      beltBTC,
      btcb,
      7  // Pool id
    );
    pancake_route = [belt, wbnb, btcb];
  }
}
