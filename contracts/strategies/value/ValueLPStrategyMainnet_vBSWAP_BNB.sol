//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "../../base/value-base/ValueMasterChefStrategyLP.sol";

contract ValueLPStrategyMainnet_vBSWAP_BNB is ValueMasterChefStrategyLP {

  address public vbswap_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x8275397136568949Ae499FbC02CB73b7b0Ef1A33);
    address vbswap = address(0x4f0ed527e8A95ecAA132Af214dFd41F30b361600);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    ValueMasterChefStrategyLP.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0xd56339F80586c08B7a4E3a68678d16D37237Bd96), // master chef contract
      wbnb,
      15  // Pool id
    );
    //Valueswap routes take Pair addresses, not token addresses.
    vBSWAP2Reward = [underlying];
    swapRoutes[vbswap] = [underlying];
  }
}
