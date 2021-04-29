//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueStakePoolStrategyLP.sol";

contract IronStrategyMainnet_IRON_STEEL is ValueStakePoolStrategyLP {

  address public iron_steel_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xb85AeE0306422bA4972cdB9F4B32C6162E393ca4);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address iron = address(0x7b65B489fE53fCE1F6548Db886C08aD73111DDd8);
    address steel = address(0x9001eE054F1692feF3A48330cB543b6FEc6287eb);
    address dnd = address(0x34EA3F7162E6f6Ed16bD171267eC180fD5c848da);
    address steelbnbLP = address(0xed2d6e9E400705f41C24dDa2e088ADbfD47C5818);
    address busdbnbLP = address(0x522361C3aa0d81D1726Fa7d40aA14505d0e097C9);
    address ironbusdLP = address(0x09D6afB74E3a40b24425EE215fA367be971b4aF3);
    address dndbnbLP = address(0x408Aa94EDE4c1BDC3295C2Ff6a82233823C2BCBe);
    ValueStakePoolStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x4564a2Ec4454dD5d8FD840e426A49a78f9F17f35), // master chef contract
      wbnb,
      dnd,
      0  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    stratReward2NotifyReward = [dndbnbLP];
    swapRoutes[iron] = [busdbnbLP, ironbusdLP];
    swapRoutes[steel] = [steelbnbLP];
  }
}
