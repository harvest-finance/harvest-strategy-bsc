pragma solidity 0.6.12;

import "./OneInchStrategy_1INCH_renBTC.sol";


/**
* This strategy is for the 1INCH/renBTC LP token on 1inch
*/
contract OneInchStrategyMainnet_1INCH_renBTC is OneInchStrategy_1INCH_renBTC {

  bool public unused_is_1inch;

  constructor(
    address _storage,
    address _vault
  ) OneInchStrategy_1INCH_renBTC (
    _storage,
    _vault,
    address(0xe3f6509818ccf031370bB4cb398EB37C21622ac4), // underlying
    address(0xCB06dF7F0Be5B8Bb261d294Cf87C794EB9Da85b1), // pool
    address(0xdaF66c0B7e8E2FC76B15B07AD25eE58E04a66796)  // 1inch-bnb LP
  ) public {
    require(token1 == renBTC, "token1 mismatch");
  }
}
