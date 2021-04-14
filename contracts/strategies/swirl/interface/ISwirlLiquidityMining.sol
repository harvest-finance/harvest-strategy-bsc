// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ISwirlLiquidityMining {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
    function claim() external;
    function userInfo(address _user) external view returns (uint256 amount, uint256 rewardDebt, uint256);
    function liquidityMining() external view returns (address lpToken, uint256, uint256);
    function massUpdatePools() external;
}
