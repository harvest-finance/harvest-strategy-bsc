// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IRewardPool {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function emergencyWithdraw(uint256 _pid) external;
    function userInfo(uint256 _pid, address _user) external view returns (uint256 amount, uint256 rewardDebt);
    function poolInfo(uint256 _pid) external view returns (address lpToken, uint256, uint256, uint256, bool);
    function massUpdatePools() external;
    function userPendingRewards(uint256 _pid, address _user) external view returns (uint256 amount);
}
