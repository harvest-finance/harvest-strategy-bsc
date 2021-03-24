pragma solidity 0.6.12;

import "../../base/venus-base/VenusFoldStrategy.sol";

contract VenusFoldStrategyMainnet_BETH is VenusFoldStrategy {

  address public beth_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x250632378E573c6Be1AC2f97Fcdf00515d0Aa91B); //BETH
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vbeth = address(0x972207A639CC1B374B893cc33Fa251b55CEB7c07);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    VenusFoldStrategy.initializeStrategy(
      _storage,
      underlying,
      vbeth,
      _vault,
      comptroller,
      venus,
      550, //collateralFactorNumerator
      1000, //collateralFactorDenominator
      5 //Folds
    );
    liquidationPath = [venus, wbnb, eth, underlying];
  }
}
