//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_MAMZN_UST is PancakeMasterChefStrategy {

  address public mamzn_ust_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xC05654C66756eBB82c518598c5f1ea1a0199a563);
    address mamzn = address(0x3947B992DC0147D2D89dF0392213781b04B25075);
    address ust = address(0x23396cF899Ca06c4472205fC903bDB4de249D6fC);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      292,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[mamzn] = [cake, wbnb, busd, ust, mamzn];
    pancakeswapRoutes[ust] = [cake, wbnb, busd, ust];
  }
}
