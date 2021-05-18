//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./PopsicleStrategy.sol";

contract PopsicleStrategtMainnet_ICE_BNBv2 is PopsicleStrategy {

  address public ice_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x51F914a192a97408D991FddDAFB8F8537C5Ffb0a);
    address ice = address(0xf16e81dce15B08F326220742020379B855B87DF9);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PopsicleStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xbf513aCe2AbDc69D38eE847EFFDaa1901808c31c), // master chef contract
      wbnb,
      0,  // Pool id
      true // is LP asset
    );
    ice2bnb = [ice, wbnb];
    sushiswapRoutes[ice] = [wbnb, ice];
  }
}
