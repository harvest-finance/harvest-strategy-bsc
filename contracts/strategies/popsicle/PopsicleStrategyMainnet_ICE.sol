//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract PopsicleStrategtMainnet_ICE is GeneralMasterChefStrategy {

  address public ice_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address ice = address(0xf16e81dce15B08F326220742020379B855B87DF9);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      ice,
      _vault,
      address(0x05200cB2Cee4B6144B2B2984E246B52bB1afcBD0), // master chef contract
      ice,
      0,  // Pool id
      false // is LP asset
    );
  }
}
