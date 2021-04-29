//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../../base/venus-base/VenusFoldStrategyV2.sol";

contract VenusFoldStrategyV2Mainnet_USDT is VenusFoldStrategyV2 {

  address public usdt_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x55d398326f99059fF775485246999027B3197955);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vusdt = address(0xfD5840Cd36d94D7229439859C0112a4185BC0255);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    VenusFoldStrategyV2.initializeStrategy(
      _storage,
      underlying,
      vusdt,
      _vault,
      comptroller,
      venus,
      550, //collateralFactorNumerator
      1000, //collateralFactorDenominator
      0 //Folds
    );
    liquidationPath = [venus, wbnb, busd, underlying];
  }
}
