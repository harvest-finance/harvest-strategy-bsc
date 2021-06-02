//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/mdex-base/MdexMasterChefStrategy.sol";

contract MdexStrategyMainnet_ETH_USDT is MdexMasterChefStrategy {

  address public eth_usdt_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x0FB881c078434b1C0E4d0B64d8c64d12078b7Ce2);
    address usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address mdx = address(0x9C65AB58d8d978DB963e63f2bfB7121627e3a739);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    MdexMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xc48FE252Aa631017dF253578B1405ea399728A50), // master chef contract
      wbnb,
      29,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[usdt] = [wbnb, usdt];
    pancakeswapRoutes[eth] = [wbnb, eth];
    mdexMDX2BNB = [mdx, wbnb];
  }
}
