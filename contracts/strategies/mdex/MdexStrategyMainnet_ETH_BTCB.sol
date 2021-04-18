//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/mdex-base/MdexMasterChefStrategy.sol";

contract MdexStrategyMainnet_ETH_BTCB is MdexMasterChefStrategy {

  address public eth_btcb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x577d005912C49B1679B4c21E334FdB650E92C077);
    address btcb = address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address mdx = address(0x9C65AB58d8d978DB963e63f2bfB7121627e3a739);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    MdexMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xc48FE252Aa631017dF253578B1405ea399728A50), // master chef contract
      wbnb,
      30,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[btcb] = [wbnb, btcb];
    pancakeswapRoutes[eth] = [wbnb, eth];
    mdexMDX2BNB = [mdx, wbnb];
  }
}
