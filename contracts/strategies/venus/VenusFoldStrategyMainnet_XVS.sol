pragma solidity 0.6.12;

import "../../base/venus-base/VenusFoldStrategy.sol";

contract VenusFoldStrategyMainnet_XVS is VenusFoldStrategy {

  address public xvs_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63); //XVS
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address vxvs = address(0x151B1e2635A717bcDc836ECd6FbB62B674FE3E1D);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    address pancakeRouter = address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    VenusFoldStrategy.initializeStrategy(
      _storage,
      underlying,
      vxvs,
      _vault,
      comptroller,
      venus,
      pancakeRouter,
      550, //collateralFactorNumerator
      1000, //collateralFactorDenominator
      0 //Folds
    );
  }
}
