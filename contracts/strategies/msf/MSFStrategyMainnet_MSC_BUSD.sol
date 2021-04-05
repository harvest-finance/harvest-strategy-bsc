//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract MSFStrategyMainnet_MSC_BUSD is GeneralMasterChefStrategy {

  address public msc_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xbCbF0C95C94798fFEF0e71A087a7E98F29D5C0Ee);
    address mss = address(0xAcABD3f9b8F76fFd2724604185Fa5AFA5dF25aC6);
    address msc = address(0x8C784C49097Dcc637b93232e15810D53871992BF);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x3646DE962ff41462cc244b2379E7289B9b751BE1), // master chef contract
      mss,
      0,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[msc] = [mss, busd, msc];
    pancakeswapRoutes[busd] = [mss, busd];
  }
}
