//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./DeflateStrategy.sol";

contract DeflateStrategyMainnet_BLN_BNB is DeflateStrategy {

  address public bln_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x00a70Fb0D636cE097b4c8789997057Daf5fa189C);
    address bln = address(0x887bf46573b9a77c4060919E786B881f08f15de4);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    DeflateStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x95030532D65C7344347E61Ab96273B6B110385F2), // master chef contract
      wbnb,  //notify in wbnb because of token transfer fee on BLN
      0,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[bln] = [wbnb, bln];
    pancakeBLN2WBNB = [bln, wbnb];
  }
}
