//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueStakePoolStrategyLP.sol";

contract IronStrategyMainnet_IRON_BUSD is ValueStakePoolStrategyLP {

  address public iron_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x09D6afB74E3a40b24425EE215fA367be971b4aF3);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address iron = address(0x7b65B489fE53fCE1F6548Db886C08aD73111DDd8);
    address steel = address(0x9001eE054F1692feF3A48330cB543b6FEc6287eb);
    address steelbnbLP = address(0xed2d6e9E400705f41C24dDa2e088ADbfD47C5818);
    address busdbnbLP = address(0x522361C3aa0d81D1726Fa7d40aA14505d0e097C9);
    ValueStakePoolStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x9c0B31833B7B67Ad751e4B8Fd307fc65C5304eE9), // master chef contract
      busd,
      steel,
      0  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    stratReward2NotifyReward = [steelbnbLP, busdbnbLP];
    swapRoutes[iron] = [underlying];
  }
}
