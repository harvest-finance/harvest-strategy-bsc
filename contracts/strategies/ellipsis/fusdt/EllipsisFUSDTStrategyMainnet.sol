//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./EllipsisFUSDTStrategy.sol";

contract EllipsisFUSDTStrategyMainnet is EllipsisFUSDTStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x373410A99B64B089DFE16F1088526D399252dacE);
    address eps = address(0xA7f552078dcC247C2684336020c03648500C6d9F);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address liquidityPool = address(0xf17814d515d3128753befd56cCeCEC2a0A41015F);
    EllipsisFUSDTStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xcce949De564fE60e7f96C85e55177F8B9E4CF61b), // stakingPool
      eps,
      liquidityPool,
      2  // Pool id
    );
    pancake_EPS2BUSD = [eps, wbnb, busd];
    pancake_ICE2EPS = [ice, wbnb, eps];
  }
}
