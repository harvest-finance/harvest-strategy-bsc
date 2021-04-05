//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./Ellipsis3PoolStrategy.sol";

contract Ellipsis3PoolStrategyMainnet is Ellipsis3PoolStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xaF4dE8E872131AE328Ce21D909C74705d3Aaf452);
    address eps = address(0xA7f552078dcC247C2684336020c03648500C6d9F);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address liquidityPool = address(0x160CAed03795365F3A589f10C379FfA7d75d4E76);
    Ellipsis3PoolStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xcce949De564fE60e7f96C85e55177F8B9E4CF61b), // stakingPool
      eps,
      liquidityPool,
      1  // Pool id
    );
    pancake_EPS2BUSD = [eps, wbnb, busd];
  }
}
