pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_LINK_BNB is PancakeMasterChefStrategy {

  address public link_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xaeBE45E3a03B734c68e5557AE04BFC76917B4686);
    address link = address(0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      7,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[link] = [cake, wbnb, link];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
