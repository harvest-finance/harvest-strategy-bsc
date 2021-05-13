//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./WsbFarmStrategyMainnet.sol";

contract WsbFarmStrategyMainnet_WSB_BNB is WsbFarmStrategyMainnet {

  address public wsb_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xE66783Ef2E2bC51958C032F04a37b6F060581fB9);
    address wsb = address(0x22168882276e5D5e1da694343b41DD7726eeb288);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    WsbFarmStrategyMainnet.initialize(
      _storage,
      underlying,
      _vault,
      address(0xd51c66DA199d253B28A0E707A017db0c1F468C2F), // reward pool
      wsb
    );

    pancakeswapRoutes[wbnb] = [wsb, wbnb];
  }
}
