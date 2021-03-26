// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IibAsset {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _share) external;
    function totalToken() external view returns(uint256);
    function totalSupply() external view returns(uint256);
}
