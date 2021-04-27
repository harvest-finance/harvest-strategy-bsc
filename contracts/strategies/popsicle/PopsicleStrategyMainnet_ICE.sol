//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./PopsicleStrategy.sol";

contract PopsicleStrategtMainnet_ICE is PopsicleStrategy {

  address public ice_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address ice = address(0xf16e81dce15B08F326220742020379B855B87DF9);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PopsicleStrategy.initializeStrategy(
      _storage,
      ice,
      _vault,
      address(0x05200cB2Cee4B6144B2B2984E246B52bB1afcBD0), // master chef contract
      wbnb,
      0,  // Pool id
      false // is LP asset
    );
    ice2bnb = [ice, wbnb];
    sushiswapRoutes[ice] = [wbnb, ice];
  }
}
