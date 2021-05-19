//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyDepositFee.sol";

contract NeonicStrategyMainnet_NEON_CAKE is GeneralMasterChefStrategyDepositFee {

  address public neon_cake_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xEAbBe7646B1D3ba1f3D32c8439ec828fD653cB64);
    address neon = address(0x94026f0227cE0c9611e8a228f114F9F19CC3Fa87);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    GeneralMasterChefStrategyDepositFee.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x045502eE488806BDF22928B6228BDD162B5056f6), // master chef contract
      neon,
      2,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[cake] = [neon, cake];
  }
}
