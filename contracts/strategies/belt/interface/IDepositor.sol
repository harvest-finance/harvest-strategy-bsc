// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IDepositor {
    function add_liquidity(uint256[4] calldata amounts, uint256 min_amount) external;
}
