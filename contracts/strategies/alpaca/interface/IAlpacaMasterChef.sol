// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IAlpacaMasterChef {
    function deposit(address _for, uint256 _pid, uint256 _amount) external;
    function withdraw(address _for, uint256 _pid, uint256 _amount) external;
    function userInfo(uint256 _pid, address _user) external view returns (uint256 amount, uint256 rewardDebt);
    function poolInfo(uint256 _pid) external view returns (address lpToken, uint256, uint256, uint256);
    function massUpdatePools() external;
}
