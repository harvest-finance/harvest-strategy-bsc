pragma solidity 0.6.12;

interface SNXRewardInterface {
    function withdraw(uint) external;
    function getReward() external;
    function stake(uint) external;
    function deposit(uint) external;
    function balanceOf(address) external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function exit() external;
    function withdrawAll() external;
}
