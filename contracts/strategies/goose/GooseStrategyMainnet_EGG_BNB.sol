//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract GooseStrategyMainnet_EGG_BNB is GeneralMasterChefStrategy {

  address public egg_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xd1B59D11316E87C3a0A069E80F590BA35cD8D8D3);
    address egg = address(0xF952Fc3ca7325Cc27D15885d37117676d25BfdA6);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xe70E9185F5ea7Ba3C5d63705784D8563017f2E57), // master chef contract
      egg,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[wbnb] = [egg, wbnb];
  }
}
