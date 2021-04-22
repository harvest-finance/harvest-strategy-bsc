// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface I3PoolDeposit {
    function add_liquidity(uint256[3] calldata amounts, uint256 min_amount) external;
}
