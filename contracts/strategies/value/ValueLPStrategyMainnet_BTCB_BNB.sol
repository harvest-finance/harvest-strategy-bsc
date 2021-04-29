//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueMasterChefStrategyLP.sol";

contract ValueLPStrategyMainnet_BTCB_BNB is ValueMasterChefStrategyLP {

  address public btcb_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x2e66669a7aa5Ab8ADC1b9FbbE6D00a1B34734A25);
    address btcb = address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vbswapbnbLP = address(0x8DD39f0a49160cDa5ef1E2a2fA7396EEc7DA8267);
    ValueMasterChefStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xd56339F80586c08B7a4E3a68678d16D37237Bd96), // master chef contract
      wbnb,
      2  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    vBSWAP2Reward = [vbswapbnbLP];
    swapRoutes[btcb] = [underlying];
  }
}
