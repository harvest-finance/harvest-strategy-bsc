//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./MasterUraniumStrategy.sol";

contract UraniumStrategyMainnet_RADS_BUSD is MasterUraniumStrategy {

    address public rads_busd_unused; // just a differentiator for the bytecode

    constructor() public {}

    function initializeStrategy(
        address _storage,
        address _vault
    ) public initializer {
        address underlying = address(0xA08c4571b395f81fBd3755d44eaf9a25C9399a4a);
        address busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        address rads = address(0x670De9f45561a2D02f283248F65cbd26EAd861C8);
        MasterUraniumStrategy.initializeStrategy(
            _storage,
            underlying,
            _vault,
            address(0xF3ca45633B2b2C062282ab38de74EAd2B76E8800), // master chef contract
            busd,
            1,  // Pool id
            true // is LP asset
        );
        pancakeswapRoutes[rads] = [busd, rads];
    }
}