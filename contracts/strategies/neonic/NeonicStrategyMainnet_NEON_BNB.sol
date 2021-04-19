//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyDepositFee.sol";

contract NeonicStrategyMainnet_NEON_BNB is GeneralMasterChefStrategyDepositFee {

  address public neon_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x1C0641d2677703DEcfA8E49E6C90E7E462007CA4);
    address neon = address(0x94026f0227cE0c9611e8a228f114F9F19CC3Fa87);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    GeneralMasterChefStrategyDepositFee.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x045502eE488806BDF22928B6228BDD162B5056f6), // master chef contract
      neon,
      0,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[wbnb] = [neon, wbnb];
  }
}
