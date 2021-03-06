//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../../base/venus-base/VenusFoldStrategyV2.sol";

contract VenusFoldStrategyV2Mainnet_USDC is VenusFoldStrategyV2 {

  address public usdc_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vusdc = address(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    VenusFoldStrategyV2.initializeStrategy(
      _storage,
      underlying,
      vusdc,
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
