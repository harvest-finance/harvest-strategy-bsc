// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

// https://bscscan.com/address/0x7680c89eb3e58dec4d38093b4803be2b7f257360#code
interface IVAIVault {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
    function claim() external;
    function pendingXVS(address _user) external view returns (uint256);
    function userInfo(address _user) external view returns (uint256, uint256);
    function updatePendingRewards() external;
}
