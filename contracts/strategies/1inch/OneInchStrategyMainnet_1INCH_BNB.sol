//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./OneInchStrategy_1INCH_BNB.sol";


/**
* This strategy is for the 1INCH/BNB LP token on 1inch
*/
contract OneInchStrategyMainnet_1INCH_BNB is OneInchStrategy_1INCH_BNB {

  constructor(
    address _storage,
    address _vault
  ) OneInchStrategy_1INCH_BNB (
    _storage,
    _vault,
    address(0xdaF66c0B7e8E2FC76B15B07AD25eE58E04a66796), // underlying
    address(0x5D0EC1F843c1233D304B96DbDE0CAB9Ec04D71EF) // pool
  ) public {
    require(token1 == oneInch, "token1 mismatch");
  }
}
