//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_ETH_BNB is PancakeMasterChefStrategy {

  address public eth_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x74E4716E431f45807DCF19f284c7aA99F18a4fbc);
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      261,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[eth] = [cake, wbnb, eth];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
