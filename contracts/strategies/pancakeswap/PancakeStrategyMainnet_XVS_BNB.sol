pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_XVS_BNB is PancakeMasterChefStrategy {

  address public xvs_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x41182c32F854dd97bA0e0B1816022e0aCB2fc0bb);
    address xvs = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      13,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[xvs] = [cake, wbnb, xvs];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
