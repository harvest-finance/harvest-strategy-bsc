//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/venus-base/VenusFoldStrategy.sol";

contract VenusFoldStrategyMainnet_BTCB is VenusFoldStrategy {

  address public btcb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vbtc = address(0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    VenusFoldStrategy.initializeStrategy(
      _storage,
      underlying,
      vbtc,
      _vault,
      comptroller,
      venus,
      550, //collateralFactorNumerator
      1000, //collateralFactorDenominator
      0 //Folds
    );
    liquidationPath = [venus, wbnb, underlying];
  }
}
