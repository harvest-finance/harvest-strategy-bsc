//SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

interface IFarmingRewards {
    function balanceOf(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function exit() external;
    function getReward() external;
}
