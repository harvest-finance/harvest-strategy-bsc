//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./MasterUraniumStrategy.sol";

contract UraniumStrategyMainnet_RADS_BUSD is MasterUraniumStrategy {

  address public rads_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x7f5a9941ffd6c1F9F022d2EFa4233fae576cDCF7);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address rads = address(0x7ca1eBC56496E3D78E56D71A127ea9d1717c4bE0);
    MasterUraniumStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xD5aAc41D315c1d382DcF1C39D4ed9B37C224edf2), // master chef contract
      busd,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[rads] = [busd, rads];
  }
}
