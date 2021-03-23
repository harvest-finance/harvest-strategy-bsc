pragma solidity 0.6.12;

import "./GooseStrategy.sol";

contract GooseStrategyMainnet_EGG_BUSD is GooseStrategy {

  address public egg_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x19e7cbECDD23A16DfA5573dF54d98F7CaAE03019); //Cake-LP
    address egg = address(0xF952Fc3ca7325Cc27D15885d37117676d25BfdA6);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GooseStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xe70E9185F5ea7Ba3C5d63705784D8563017f2E57), // master chef contract
      egg,
      0,  // Pool id
      true // is LP asset
    );
    // egg is token0, busd is token1
    pancakeswapRoutes[busd] = [egg, busd];
  }
}
