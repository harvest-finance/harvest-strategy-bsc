//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract PopsicleStrategtMainnet_ICE_BNB is GeneralMasterChefStrategy {

  address public ice_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xFE3171B9c20d002376D4B0097207EDf54b02EA3B);
    address ice = address(0xf16e81dce15B08F326220742020379B855B87DF9);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x05200cB2Cee4B6144B2B2984E246B52bB1afcBD0), // master chef contract
      ice,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[wbnb] = [ice, wbnb];
  }
}
