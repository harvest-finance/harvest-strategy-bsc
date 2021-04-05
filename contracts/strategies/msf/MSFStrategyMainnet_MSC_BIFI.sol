//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract MSFStrategyMainnet_MSC_BIFI is GeneralMasterChefStrategy {

  address public msc_bifi_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xC3b74901838065D620Cb4e46769A0C99d0cBba92);
    address msc = address(0x8C784C49097Dcc637b93232e15810D53871992BF);
    address bifi = address(0xCa3F508B8e4Dd382eE878A314789373D80A5190A);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x171b785EB9cD898E3BeD6985C4765489334552EC), // master chef contract
      msc,
      0,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[bifi] = [msc, busd, wbnb, bifi];
  }
}
