pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract MSFStrategyMainnet_MSB is GeneralMasterChefStrategy {

  address public msb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x9e0D278168fdd4efEa3c5B6c9e8d06E5B05e66D4);
    address msc = address(0x8C784C49097Dcc637b93232e15810D53871992BF);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x01C4fBD2142244fc9178e124505F702dbcA9b7f6), // master chef contract
      busd,
      1,  // Pool id
      false // is LP asset
    );
    pancakeswapRoutes[underlying] = [busd, msc, underlying];
  }
}
