// SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;

interface IStakePool {
    event Deposit(address indexed account, uint256 amount);
    event AddRewardPool(uint256 indexed poolId);
    event UpdateRewardPool(uint256 indexed poolId, uint256 endRewardBlock, uint256 rewardPerBlock);
    event PayRewardPool(uint256 indexed poolId, address indexed rewardToken, address indexed account, uint256 pendingReward, uint256 rebaseAmount, uint256 paidReward);
    event UpdateRewardRebaser(uint256 indexed poolId, address rewardRebaser);
    event UpdateRewardMultiplier(uint256 indexed poolId, address rewardMultiplier);
    event Withdraw(address indexed account, uint256 amount);

    function version() external view returns (uint256);

    function stakeToken() external view returns (address);

    function initialize(
        address _stakeToken,
        uint256 _unstakingFrozenTime,
        address _rewardFund,
        address _timelock
    ) external;

    function stake(uint256) external;

    function stakeFor(address _account) external;

    function withdraw(uint256) external;

    function exit() external;

    function getReward(uint8 _pid, address _account) external;

    function getAllRewards(address _account) external;

    function claimReward() external;

    function pendingReward(uint8 _pid, address _account) external view returns (uint256);

    function allowRecoverRewardToken(address _token) external view returns (bool);

    function getRewardPerBlock(uint8 pid) external view returns (uint256);

    function rewardPoolInfoLength() external view returns (uint256);

    function unfrozenStakeTime(address _account) external view returns (uint256);

    function emergencyWithdraw() external;

    function updateReward() external;

    function updateReward(uint8 _pid) external;

    function updateRewardPool(
        uint8 _pid,
        uint256 _endRewardBlock,
        uint256 _rewardPerBlock
    ) external;

    function getRewardMultiplier(
        uint8 _pid,
        uint256 _from,
        uint256 _to,
        uint256 _rewardPerBlock
    ) external view returns (uint256);

    function getRewardRebase(
        uint8 _pid,
        address _rewardToken,
        uint256 _pendingReward
    ) external view returns (uint256);

    function updateRewardRebaser(uint8 _pid, address _rewardRebaser) external;

    function updateRewardMultiplier(uint8 _pid, address _rewardMultiplier) external;

    function getUserInfo(uint8 _pid, address _account)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 accumulatedEarned,
            uint256 lockReward,
            uint256 lockRewardReleased
        );

    function addRewardPool(
        address _rewardToken,
        address _rewardRebaser,
        address _rewardMultiplier,
        uint256 _startBlock,
        uint256 _endRewardBlock,
        uint256 _rewardPerBlock,
        uint256 _lockRewardPercent,
        uint256 _startVestingBlock,
        uint256 _endVestingBlock
    ) external;
}
