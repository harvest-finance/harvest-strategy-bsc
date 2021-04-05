//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefHodlStrategy.sol";

contract PancakeHodlStrategyMainnet_ETH_BNB is PancakeMasterChefHodlStrategy {

  address public eth_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x70D8929d04b60Af4fb9B58713eBcf18765aDE422);
    address cake = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    PancakeMasterChefHodlStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      cake,
      14,  // Pool id
      address(0x3D5B0a8CD80e2A87953525fC136c33112E4b885a), // Cake Vault fCake
      address(0x0000000000000000000000000000000000000000)  // manually set it later
    );
  }
}
