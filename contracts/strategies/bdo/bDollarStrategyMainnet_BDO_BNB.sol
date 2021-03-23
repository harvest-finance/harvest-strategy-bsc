pragma solidity 0.6.12;

import "../../base/masterchef/GeneralMasterChefStrategy.sol";

contract bDollarStrategyMainnet_BDO_BNB is GeneralMasterChefStrategy {

  address public bdo_bnb_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0x74690f829fec83ea424ee1F1654041b2491A7bE9); //Cake-LP
    address bdo = address(0x190b589cf9Fb8DDEabBFeae36a813FFb2A702454);
    address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address sbdo = address(0x0d9319565be7f53CeFE84Ad201Be3f40feAE2740);
    address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    GeneralMasterChefStrategy.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x948dB1713D4392EC04C86189070557C5A8566766), // master chef contract
      sbdo,
      2,  // Pool id
      true // is LP asset
    );
    // bdo is token0, busd is token1
    pancakeswapRoutes[bdo] = [sbdo, busd, bdo];
    pancakeswapRoutes[wbnb] = [sbdo, busd, wbnb];
  }
}
