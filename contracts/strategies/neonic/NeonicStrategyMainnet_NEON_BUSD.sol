//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyDepositFee.sol";

contract NeonicStrategyMainnet_NEON_BUSD is GeneralMasterChefStrategyDepositFee {

  address public neon_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xaB953EFFA07e7FB7E694b25169ef515Aa8Ae9Daf);
    address neon = address(0x94026f0227cE0c9611e8a228f114F9F19CC3Fa87);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GeneralMasterChefStrategyDepositFee.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x045502eE488806BDF22928B6228BDD162B5056f6), // master chef contract
      neon,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[busd] = [neon, busd];
  }
}
