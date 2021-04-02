//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract bDollarStrategyMainnet_BDO_BUSD is GeneralMasterChefStrategy {

  address public bdo_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xc5b0d73A7c0E4eaF66baBf7eE16A2096447f7aD6);
    address bdo = address(0x190b589cf9Fb8DDEabBFeae36a813FFb2A702454);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address sbdo = address(0x0d9319565be7f53CeFE84Ad201Be3f40feAE2740);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x948dB1713D4392EC04C86189070557C5A8566766), // master chef contract
      sbdo,
      0,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[bdo] = [sbdo, busd, bdo];
    pancakeswapRoutes[busd] = [sbdo, busd];
  }
}
