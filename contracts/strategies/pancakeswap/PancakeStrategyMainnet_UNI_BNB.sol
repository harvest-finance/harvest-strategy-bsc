pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_UNI_BNB is PancakeMasterChefStrategy {

  address public uni_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x4269e7F43A63CEA1aD7707Be565a94a9189967E9);
    address uni = address(0xBf5140A22578168FD562DCcF235E5D43A02ce9B1);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      25,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[uni] = [cake, wbnb, uni];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
