//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyNewRouter.sol";

contract BeltStrategyMainnet_BELT_BNB is GeneralMasterChefStrategyNewRouter {

  address public belt_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xF3Bc6FC080ffCC30d93dF48BFA2aA14b869554bb);
    address belt = address(0xE0e514c71282b6f4e823703a39374Cf58dc3eA4f);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    GeneralMasterChefStrategyNewRouter.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xD4BbC80b9B102b77B21A06cb77E954049605E6c1), // master chef contract
      belt,
      11,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[wbnb] = [belt, wbnb];
  }
}
