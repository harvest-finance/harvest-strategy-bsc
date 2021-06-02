//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/mdex-base/MdexMasterChefStrategy.sol";

contract MdexStrategyMainnet_MDX_USDT is MdexMasterChefStrategy {

  address public mdx_usdt_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xe1cBe92b5375ee6AfE1B22b555D257B4357F6C68);
    address mdx = address(0x9C65AB58d8d978DB963e63f2bfB7121627e3a739);
    address usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    MdexMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xc48FE252Aa631017dF253578B1405ea399728A50), // master chef contract
      wbnb,
      43,  // Pool id
      true // is LP asset
    );
    mdexRoutes[mdx] = [wbnb, mdx];
    pancakeswapRoutes[usdt] = [wbnb, usdt];
    mdexMDX2BNB = [mdx, wbnb];
  }
}
