//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./WsbFarmStrategyMainnet.sol";

contract WsbFarmStrategyMainnet_WSB_BUSD is WsbFarmStrategyMainnet {

  address public wsb_cake_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x93aC8BdcCC8B47E09611fde0F294bf6C80579e51);
    address wsb = address(0x22168882276e5D5e1da694343b41DD7726eeb288);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    WsbFarmStrategyMainnet.initialize(
      _storage,
      underlying,
      _vault,
      address(0xE6b9d9201f5137bba96DDfcb84aa5Ed02bfE0713), // reward pool
      wsb
    );

    pancakeswapRoutes[busd] = [wsb, wbnb, busd];
  }
}
