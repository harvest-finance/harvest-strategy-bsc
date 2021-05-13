//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./WsbFarmStrategyMainnet.sol";

contract WsbFarmStrategyMainnet_WSB_CAKE is WsbFarmStrategyMainnet {

  address public wsb_cake_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xdE92DE18fC24afC56c0712b60D946Ea3f4BF55E8);
    address wsb = address(0x22168882276e5D5e1da694343b41DD7726eeb288);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    WsbFarmStrategyMainnet.initialize(
      _storage,
      underlying,
      _vault,
      address(0xdee5713509EB314F4e3fecAC4608101C0e710e02), // reward pool
      wsb
    );

    pancakeswapRoutes[cake] = [wsb, wbnb, cake];
  }
}
