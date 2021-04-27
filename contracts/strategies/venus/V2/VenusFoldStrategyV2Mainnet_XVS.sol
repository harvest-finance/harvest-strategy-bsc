//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../../base/venus-base/VenusFoldStrategyV2.sol";

contract VenusFoldStrategyV2Mainnet_XVS is VenusFoldStrategyV2 {

  address public xvs_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address venus = address(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
    address vxvs = address(0x151B1e2635A717bcDc836ECd6FbB62B674FE3E1D);
    address comptroller = address(0xfD36E2c2a6789Db23113685031d7F16329158384);
    VenusFoldStrategyV2.initializeStrategy(
      _storage,
      underlying,
      vxvs,
      _vault,
      comptroller,
      venus,
      550, //collateralFactorNumerator
      1000, //collateralFactorDenominator
      0 //Folds
    );
  }
}
