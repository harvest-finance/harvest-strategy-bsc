pragma solidity 0.6.12;

import "./AlpacaLendingStrategy.sol";

contract AlpacaStrategyMainnet_BUSD is AlpacaLendingStrategy {

  address public busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address alpaca = address(0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address ibusd = address(0x7C9e73d4C71dae564d41F78d56439bB4ba87592f);
    AlpacaLendingStrategy.initializeStrategy(
      _storage,
      busd,
      _vault,
      address(0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F), // master chef contract
      alpaca,
      3,  // Pool id
      ibusd
    );
    pancakeswapRoutes[busd] = [alpaca, wbnb, busd];
  }
}
