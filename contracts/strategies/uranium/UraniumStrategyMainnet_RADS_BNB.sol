//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./MasterUraniumStrategy.sol";

contract UraniumStrategyMainnet_RADS_BNB is MasterUraniumStrategy {

  address public rads_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x19b6E14D62bf222add5f1D47fCb56Dd973029d00);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address rads = address(0x7ca1eBC56496E3D78E56D71A127ea9d1717c4bE0);
    MasterUraniumStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xD5aAc41D315c1d382DcF1C39D4ed9B37C224edf2), // master chef contract
      wbnb,
      2,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[rads] = [wbnb, rads];
  }
}
