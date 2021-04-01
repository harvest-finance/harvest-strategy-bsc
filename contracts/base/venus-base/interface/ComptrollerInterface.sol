// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

abstract contract ComptrollerInterface {
    // implemented, but missing from the interface
    function getAccountLiquidity(address account) external virtual view returns (uint, uint, uint);
    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint redeemTokens,
        uint borrowAmount) external virtual view returns (uint, uint, uint);
    function claimVenus(address holder, address[] memory vTokens) external virtual;

    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata vTokens) external virtual returns (uint[] memory);
    function exitMarket(address vToken) external virtual returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address vToken, address minter, uint mintAmount) external virtual returns (uint);
    function mintVerify(address vToken, address minter, uint mintAmount, uint mintTokens) external virtual;

    function redeemAllowed(address vToken, address redeemer, uint redeemTokens) external virtual returns (uint);
    function redeemVerify(address vToken, address redeemer, uint redeemAmount, uint redeemTokens) external virtual;

    function borrowAllowed(address vToken, address borrower, uint borrowAmount) external virtual returns (uint);
    function borrowVerify(address vToken, address borrower, uint borrowAmount) external virtual;

    function repayBorrowAllowed(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount) external virtual returns (uint);
    function repayBorrowVerify(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external virtual;

    function liquidateBorrowAllowed(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external virtual returns (uint);
    function liquidateBorrowVerify(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external virtual;

    function seizeAllowed(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external virtual returns (uint);
    function seizeVerify(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external virtual;

    function transferAllowed(address vToken, address src, address dst, uint transferTokens) external virtual returns (uint);
    function transferVerify(address vToken, address src, address dst, uint transferTokens) external virtual;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address vTokenBorrowed,
        address vTokenCollateral,
        uint repayAmount) external virtual view returns (uint, uint);

    function mintedVAIOf(address owner) external virtual view returns (uint);
    function setMintedVAIOf(address owner, uint amount) external virtual returns (uint);
    function getVAIMintRate() external virtual view returns (uint);
}
