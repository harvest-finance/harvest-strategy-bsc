//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract MSFStrategyMainnet_MSC_MSB is GeneralMasterChefStrategy {

  address public msc_msb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x7922de38FCA8F6b50a3677BA1271C0b161831CCC);
    address msc = address(0x8C784C49097Dcc637b93232e15810D53871992BF);
    address msb = address(0x9e0D278168fdd4efEa3c5B6c9e8d06E5B05e66D4);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x171b785EB9cD898E3BeD6985C4765489334552EC), // master chef contract
      msc,
      1,  // Pool id
      true // is LP asset
    );
    pancakeswapRoutes[msb] = [msc, msb];
  }
}
