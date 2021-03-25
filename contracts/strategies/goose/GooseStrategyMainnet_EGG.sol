pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract GooseStrategyMainnet_EGG is GeneralMasterChefStrategy {

  address public egg_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xF952Fc3ca7325Cc27D15885d37117676d25BfdA6);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xe70E9185F5ea7Ba3C5d63705784D8563017f2E57), // master chef contract
      underlying,
      12,  // Pool id
      false // is LP asset
    );
  }
}
