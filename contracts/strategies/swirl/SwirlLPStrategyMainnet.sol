//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./SwirlLPStrategy.sol";

contract SwirlLPStrategyMainnet is SwirlLPStrategy {

  address public swirl_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x135AeDCFb35b0b5dCf61Db7891a21253452Eb970);
    address swirl = address(0x52d86850bc8207b520340B7E39cDaF22561b9E56);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    SwirlLPStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x9FC04657C1178F857d36D8a6B028C732D78F60E0), // master chef contract
      wbnb
    );
    pancakeswapRoutes[swirl] = [wbnb, swirl];
  }
}
