// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {HookVm} from "./HookVm.sol";

contract MockHookVm is HookVm {
    function on(address addr, string memory eventOrFunctionSignature, string memory hookFunctionSignature) external {
        emit HookRegistered(addr, eventOrFunctionSignature, hookFunctionSignature);
    }

    function onEvent(string memory eventSignature, string memory hookFunctionSignature) external {
        emit HookRegistered(address(0), eventSignature, hookFunctionSignature);
    }

    function onEvent(address addr, string memory eventSignature, string memory hookFunctionSignature) external {
        emit HookRegistered(addr, eventSignature, hookFunctionSignature);
    }

    function onCall(address addr, string memory functionSignature, string memory hookFunctionSignature) external {
        emit HookRegistered(addr, functionSignature, hookFunctionSignature);
    }

    function onSchedule(string memory cronExpression, string memory hookFunctionSignature) external {
        emit HookRegistered(address(0), cronExpression, hookFunctionSignature);
    }

    function transaction() external view returns (Transaction memory) {
        return Transaction({from: msg.sender, to: msg.sender, value: 0, nonce: 0, data: msg.data});
    }
}
