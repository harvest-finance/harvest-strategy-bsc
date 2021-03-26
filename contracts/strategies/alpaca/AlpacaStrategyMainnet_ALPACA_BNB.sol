pragma solidity 0.6.12;

import "./AlpacaMasterChefStrategy.sol";

contract AlpacaStrategyMainnet_ALPACA_BNB is AlpacaMasterChefStrategy {

  address public alpaca_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xF3CE6Aac24980E6B657926dfC79502Ae414d3083);
    address alpaca = address(0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    AlpacaMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F), // master chef contract
      alpaca,
      4,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[wbnb] = [alpaca, wbnb];
  }
}
