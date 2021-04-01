pragma solidity 0.6.12;

import "../../base/venus-base/VenusFoldStrategy.sol";

contract VenusFoldStrategyMainnet_DAI is VenusFoldStrategy {

  address public dai_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vdai = address(0x334b3eCB4DCa3593BCCC3c7EBD1A1C1d1780FBF1);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    VenusFoldStrategy.initializeStrategy(
      _storage,
      underlying,
      vdai,
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
