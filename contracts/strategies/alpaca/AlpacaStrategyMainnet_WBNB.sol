pragma solidity 0.6.12;

import "./AlpacaLendingStrategy.sol";

contract AlpacaStrategyMainnet_WBNB is AlpacaLendingStrategy {

  address public wbnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address alpaca = address(0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address ibbnb = address(0xd7D069493685A581d27824Fc46EdA46B7EfC0063);
    AlpacaLendingStrategy.initializeStrategy(
      _storage,
      wbnb,
      _vault,
      address(0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F), // master chef contract
      alpaca,
      1,  // Pool id
      ibbnb
    );
    pancakeswapRoutes[wbnb] = [alpaca, wbnb];
  }
}
