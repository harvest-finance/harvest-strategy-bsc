//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

import "./MasterUraniumStrategy.sol";

contract UraniumStrategyMainnet_RADS_BNB is MasterUraniumStrategy {

    address public rads_bnb_unused; // just a differentiator for the bytecode

    constructor() public {}

    function initializeStrategy(
        address _storage,
        address _vault
    ) public initializer {
        address underlying = address(0xdD0C4a96A43b36d91F4FEdf83489B954C287886A);
        address wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        address rads = address(0x670De9f45561a2D02f283248F65cbd26EAd861C8);
        MasterUraniumStrategy.initializeStrategy(
            _storage,
            underlying,
            _vault,
            address(0xF3ca45633B2b2C062282ab38de74EAd2B76E8800), // master chef contract
            wbnb,
            2,  // Pool id
            true // is LP asset
        );
        pancakeswapRoutes[rads] = [wbnb, rads];
    }
}