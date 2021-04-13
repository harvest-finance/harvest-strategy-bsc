//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategyDepositFee.sol";

contract SpaceStrategy_SPACE_BUSD is GeneralMasterChefStrategyDepositFee {

  address public space_busd_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x6B936c5C1FD7De08E03684b0588A87DBD8ce6b63);
    address space = address(0x0abd3E3502c15ec252f90F64341cbA74a24fba06);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    GeneralMasterChefStrategyDepositFee.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xc8cf0767fB2258b23B90636A5e21cfaD113e8182), // master chef contract
      space,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[busd] = [space, wbnb, busd];
  }
}
