//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_MTSLA_UST is PancakeMasterChefStrategy {

  address public mtsla_ust_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xEc6b56a736859AE8ea4bEdA16279Ecd8c60dA7EA);
    address mtsla = address(0xF215A127A196e3988C09d052e16BcFD365Cd7AA3);
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
      289,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[mtsla] = [cake, wbnb, busd, ust, mtsla];
    pancakeswapRoutes[ust] = [cake, wbnb, busd, ust];
  }
}
