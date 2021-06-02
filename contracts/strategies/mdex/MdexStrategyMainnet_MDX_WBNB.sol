//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/mdex-base/MdexMasterChefStrategy.sol";

contract MdexStrategyMainnet_MDX_WBNB is MdexMasterChefStrategy {

  address public mdx_wbnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xAf9Aa53146C5752BF6068A84B970E9fBB22a87bc);
    address mdx = address(0x9C65AB58d8d978DB963e63f2bfB7121627e3a739);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    MdexMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xc48FE252Aa631017dF253578B1405ea399728A50), // master chef contract
      wbnb,
      42,  // Pool id
      true // is LP asset
    );
    mdexRoutes[mdx] = [wbnb, mdx];
    mdexMDX2BNB = [mdx, wbnb];
  }
}
