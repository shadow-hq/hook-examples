// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface Vm {
    struct Transaction {
        /// @notice The address of the sender.
        address from;
        /// @notice The address of the recipient.
        address to;
        /// @notice The value of the transaction in wei.
        uint256 value;
        /// @notice The nonce of the transaction.
        uint256 nonce;
        /// @notice The call data of the transaction.
        bytes data;
    }

    /// @notice Registers an event hook for all contracts. The hook function will be called for all events with the given signature.
    /// @param eventSignature The signature of the event to hook. e.g. `Event(address,uint256)`
    /// @param hookFunctionSignature The signature of the hook function. e.g. `onEvent(bytes,bytes)`
    function onEvent(string memory eventSignature, string memory hookFunctionSignature) external;

    /// @notice Registers an event hook for a given contract address.
    /// @param addr The address of the contract.
    /// @param eventSignature The signature of the event to hook. e.g. `Event(address,uint256)`
    /// @param hookFunctionSignature The signature of the hook function. e.g. `onEvent(bytes,bytes)`
    function onEvent(address addr, string memory eventSignature, string memory hookFunctionSignature) external;

    /// @notice Registers a call hook for a given contract address.
    /// @param addr The address of the contract to hook.
    /// @param functionSignature The signature of the function to hook. e.g. `functionName(address,uint256)`
    /// @param hookFunctionSignature The signature of the hook function. e.g. `onFunction(bytes,bytes)`
    function onCall(address addr, string memory functionSignature, string memory hookFunctionSignature) external;

    /// @notice Registers a cron hook.
    /// @param cronExpression The cron expression to trigger the hook. e.g. `0 0 * * *` for midnight UTC every day.
    /// @param hookFunctionSignature The signature of the hook function. e.g. `onCron()`
    function onSchedule(string memory cronExpression, string memory hookFunctionSignature) external;

    /// @notice Returns the transaction that is being hooked. Can be called from any hook function.
    function transaction() external view returns (Transaction memory);
}
