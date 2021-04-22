// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IBTCPoolDeposit {
    function add_liquidity(uint256[2] calldata amounts, uint256 min_amount) external;
}
