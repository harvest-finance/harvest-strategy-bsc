//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract bDollarStrategyMainnet_SBDO_BUSD is GeneralMasterChefStrategy {

  address public sbdo_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xA0718093baa3E7AAE054eED71F303A4ebc1C076f);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address sbdo = address(0x0d9319565be7f53CeFE84Ad201Be3f40feAE2740);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x948dB1713D4392EC04C86189070557C5A8566766), // master chef contract
      sbdo,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[busd] = [sbdo, busd];
  }
}
