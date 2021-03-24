pragma solidity 0.6.12;

import "../../base/pancake-base/PancakeMasterChefStrategy.sol";

contract PancakeStrategyMainnet_CAKE is PancakeMasterChefStrategy {

  address public cake_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82); //CAKE
    PancakeMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x73feaa1eE314F8c655E354234017bE2193C9E24E), // master chef contract
      underlying,
      0,  // Pool id
      false // is LP asset
    );
  }
}
