//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyDepositFee.sol";

contract NeonicStrategyMainnet_NEON_BTCB is GeneralMasterChefStrategyDepositFee {

  address public neon_btcb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x17baE1a9FaCaA596a10C3BB90F6Dbb970847BB05);
    address neon = address(0x94026f0227cE0c9611e8a228f114F9F19CC3Fa87);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address btcb = address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    GeneralMasterChefStrategyDepositFee.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x045502eE488806BDF22928B6228BDD162B5056f6), // master chef contract
      neon,
      4,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[btcb] = [neon, busd, wbnb, btcb];
  }
}
