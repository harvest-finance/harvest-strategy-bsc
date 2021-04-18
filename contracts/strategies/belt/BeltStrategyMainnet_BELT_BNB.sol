//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract BeltStrategyMainnet_BELT_BNB is GeneralMasterChefStrategy {

  address public belt_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x83B92D283cd279fF2e057BD86a95BdEfffED6faa);
    address belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xD4BbC80b9B102b77B21A06cb77E954049605E6c1), // master chef contract
      belt,
      2,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[wbnb] = [belt, wbnb];
  }
}
