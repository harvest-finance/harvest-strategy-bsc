//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyDepositFee.sol";

contract NeonicStrategyMainnet_NEON_ETH is GeneralMasterChefStrategyDepositFee {

  address public neon_eth_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xFa7D22ec8F803F4A3eF0efc6e053d3017d77CC66);
    address neon = address(0x94026f0227cE0c9611e8a228f114F9F19CC3Fa87);
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    GeneralMasterChefStrategyDepositFee.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x045502eE488806BDF22928B6228BDD162B5056f6), // master chef contract
      neon,
      3,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[eth] = [neon, eth];
  }
}
