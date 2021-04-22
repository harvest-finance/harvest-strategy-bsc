//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./EllipsisBTCStrategy.sol";

contract EllipsisBTCStrategyMainnet is EllipsisBTCStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x2a435Ecb3fcC0E316492Dc1cdd62d0F189be5640);
    address eps = address(0xA7f552078dcC247C2684336020c03648500C6d9F);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address liquidityPool = address(0x2477fB288c5b4118315714ad3c7Fd7CC69b00bf9);
    EllipsisBTCStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xcce949De564fE60e7f96C85e55177F8B9E4CF61b), // stakingPool
      eps,
      liquidityPool,
      3  // Pool id
    );
    pancake_EPS2BTCB = [eps, wbnb, btcb];
  }
}
