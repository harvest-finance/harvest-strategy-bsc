//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueMasterChefStrategyLP.sol";

contract ValueLPStrategyMainnet_FARM_BNB is ValueMasterChefStrategyLP {

  address public farm_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x8054F464902267B1ecb4C936a3bAD2559058ab77);
    address farm = address(0x4B5C23cac08a567ecf0c1fFcA8372A45a5D33743);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vbswapbnbLP = address(0x8DD39f0a49160cDa5ef1E2a2fA7396EEc7DA8267);
    ValueMasterChefStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xd56339F80586c08B7a4E3a68678d16D37237Bd96), // master chef contract
      wbnb,
      40  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    vBSWAP2Reward = [vbswapbnbLP];
    swapRoutes[farm] = [underlying];
  }
}
