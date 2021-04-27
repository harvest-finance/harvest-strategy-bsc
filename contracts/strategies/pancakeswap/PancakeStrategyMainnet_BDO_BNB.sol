//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_BDO_BNB is PancakeMasterChefStrategy {

  address public bdo_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x4288706624e3dD839b069216eB03B8B9819C10d2);
    address bdo = address(0x190b589cf9Fb8DDEabBFeae36a813FFb2A702454);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      295,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[bdo] = [cake, wbnb, bdo];
    pancakeswapRoutes[wbnb] = [cake, wbnb];
  }
}
