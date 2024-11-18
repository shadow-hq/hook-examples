// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../../lib/shadow-std/Hook.sol";
import "../generated/GeneratedMultipliers.sol";
import "../Points.sol";

/// @notice Hooks for multiplier activity tracking.
contract Multipliers is Hook {
    // Constants
    address private constant REWARDS = 0xC6f3D10562073De863dA3562649973E8706cF981;

    string private constant SIG_INCREASE_MULTIPLIER = "function increaseMultiplier(address to, string calldata message)";
    string private constant SIG_DECREASE_MULTIPLIER = "function decreaseMultiplier(address to, string calldata message)";

    // State
    Points private immutable points;

    constructor(address pointsAddress) {
        points = Points(pointsAddress);

        // Registering call hooks
        vm.registerCallHook(REWARDS, SIG_INCREASE_MULTIPLIER, "onIncreaseMultiplier");
        vm.registerCallHook(REWARDS, SIG_DECREASE_MULTIPLIER, "onDecreaseMultiplier");
    }

    /// @notice Hook for the `increaseMultiplier` call.
    function onIncreaseMultiplier(GeneratedMultipliers.IncreaseMultiplierParams memory params) external {
        // Get the original transaction sender
        Vm.Transaction memory transaction = vm.transaction();
        points.increaseMultiplier(transaction.from, params.to);
    }

    /// @notice Hook for the `decreaseMultiplier` call.
    function onDecreaseMultiplier(GeneratedMultipliers.DecreaseMultiplierParams memory params) external {
        // Get the original transaction sender
        Vm.Transaction memory transaction = vm.transaction();
        points.decreaseMultiplier(transaction.from, params.to);
    }
}
