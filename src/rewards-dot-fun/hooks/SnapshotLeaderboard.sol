// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@shadow-std/Hook.sol";
import "../Points.sol";

/// @notice Hook to snapshot the leaderboard at midnight UTC every day.
contract SnapshotLeaderboard is Hook {
    Points private points;

    constructor(address pointsAddress) {
        points = Points(pointsAddress);

        // Registering a scheduled hook. This will run the `snapshot()` function every day at midnight UTC.
        hook.onSchedule("0 0 * * *", "snapshot");
    }

    /// @notice Hook to snapshot the leaderboard at midnight UTC every day.
    function snapshot() external {
        points.snapshotLeaderboard();
    }
}
