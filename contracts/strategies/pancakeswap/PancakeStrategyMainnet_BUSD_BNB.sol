pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_BUSD_BNB is PancakeMasterChefStrategy {

  address public busd_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x1B96B92314C44b159149f7E0303511fB2Fc4774f); //Cake-LP
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      2,  // Pool id
      true // is LP asset
    );
    // busd is token0, wbnb is token1
    pancakeswapRoutes[busd] = [cake, wbnb, busd];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
