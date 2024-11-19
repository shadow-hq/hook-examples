// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@shadow-std/Hook.sol";
import "@generated/Multipliers.gen.sol";
import "../Points.sol";

/// @notice Hooks for multiplier activity tracking.
contract Multipliers is Hook {
    // Constants
    address private constant REWARDS = 0xC6f3D10562073De863dA3562649973E8706cF981;

    // State
    Points private immutable points;

    constructor(address pointsAddress) {
        points = Points(pointsAddress);

        // Call hooks
        hook.on(REWARDS, "function increaseMultiplier(address to, string calldata message)", "onIncreaseMultiplier");
        hook.on(REWARDS, "function decreaseMultiplier(address to, string calldata message)", "onDecreaseMultiplier");
    }

    /// @notice Hook for the `increaseMultiplier` call.
    function onIncreaseMultiplier(MultipliersGenerated.IncreaseMultiplierParams memory params) external {
        // Get the original transaction sender
        HookVm.Transaction memory transaction = hook.transaction();
        points.increaseMultiplier(transaction.from, params.to);
    }

    /// @notice Hook for the `decreaseMultiplier` call.
    function onDecreaseMultiplier(MultipliersGenerated.DecreaseMultiplierParams memory params) external {
        // Get the original transaction sender
        HookVm.Transaction memory transaction = hook.transaction();
        points.decreaseMultiplier(transaction.from, params.to);
    }
}
