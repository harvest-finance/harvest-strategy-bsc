// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IMultiStrategyToken {
  function deposit(uint256 _amount, uint256 _minShares) external;
  function withdraw(uint256 _shares, uint256 _minAmount) external;
}
