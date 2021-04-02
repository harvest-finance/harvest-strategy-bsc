//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_USDT_BNB is PancakeMasterChefStrategy {

  address public usdt_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x20bCC3b8a0091dDac2d0BC30F68E6CBb97de59Cd);
    address usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      17,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[usdt] = [cake, wbnb, usdt];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
