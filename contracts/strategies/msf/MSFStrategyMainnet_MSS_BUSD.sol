pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract MSFStrategyMainnet_MSS_BUSD is GeneralMasterChefStrategy {

  address public mss_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x73601076A92E0D1bD81737B38B150D6842aa1aA1);
    address mss = address(0xAcABD3f9b8F76fFd2724604185Fa5AFA5dF25aC6);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x3646DE962ff41462cc244b2379E7289B9b751BE1), // master chef contract
      mss,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[busd] = [mss, busd];
  }
}
