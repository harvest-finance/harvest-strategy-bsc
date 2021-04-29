//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueMasterChefStrategyLP.sol";

contract ValueLPStrategyMainnet_ETH_BNB is ValueMasterChefStrategyLP {

  address public eth_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x58065F6ca40c000c71c110CeC47Fb57b7cc0B9b9);
    address eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address vbswapbnbLP = address(0x8DD39f0a49160cDa5ef1E2a2fA7396EEc7DA8267);
    ValueMasterChefStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xd56339F80586c08B7a4E3a68678d16D37237Bd96), // master chef contract
      wbnb,
      3  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    vBSWAP2Reward = [vbswapbnbLP];
    swapRoutes[eth] = [underlying];
  }
}
