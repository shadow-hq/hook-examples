// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../lib/shadow-std/Hook.sol";
import "./GeneratedTransferVolume.sol";

/// @notice Hook contract to track the volume of transfers for an ERC20 token.
contract TransferVolume is Hook {
    // State
    IERC20 private immutable erc20;

    uint256 public totalVolumeTransfered;
    mapping(uint256 => uint256) public totalVolumeTransferedPerDay;
    mapping(uint256 => mapping(address => uint256)) public volumeTransferedFromPerDayPerUser;
    mapping(uint256 => mapping(address => uint256)) public volumeTransferedToPerDayPerUser;

    constructor(address _erc20) {
        erc20 = IERC20(_erc20);

        // Register hook
        hook.on(_erc20, "event Transfer(address,address,uint256)", "onTransfer");
    }

    /// @notice Hooks on the Transfer event of an ERC20 token to track total transfer volume.
    function onTransfer(GeneratedTransferVolume.Transfer memory evt) external {
        uint256 currentDay = block.timestamp / (1 days);

        totalVolumeTransfered += evt.value;
        totalVolumeTransferedPerDay[currentDay] += evt.value;
        volumeTransferedFromPerDayPerUser[currentDay][evt.from] += evt.value;
        volumeTransferedToPerDayPerUser[currentDay][evt.to] += evt.value;
    }

    /// @notice Get the volume transferred per day for a given day range.
    function getVolumeTransferredPerDay(uint256 startTimestamp, uint256 endTimestamp)
        external
        view
        returns (uint256[] memory)
    {
        // Round down to the nearest day
        uint256 startDay = startTimestamp / (1 days);
        uint256 endDay = endTimestamp / (1 days);

        uint256[] memory volumes = new uint256[](startDay - endDay + 1);
        for (uint256 i = startDay; i <= endDay; i++) {
            volumes[i - startDay] = totalVolumeTransferedPerDay[i];
        }
        return volumes;
    }

    /// @notice Get the volume transferred per day for a given user
    function getVolumeTransferredPerDayForUser(address user, uint256 startTimestamp, uint256 endTimestamp)
        external
        view
        returns (int256[] memory)
    {
        // Round down to the nearest day
        uint256 startDay = startTimestamp / (1 days);
        uint256 endDay = endTimestamp / (1 days);

        int256[] memory volumes = new int256[](startDay - endDay + 1);
        for (uint256 i = startDay; i <= endDay; i++) {
            uint256 volumeOut = volumeTransferedFromPerDayPerUser[i][user];
            uint256 volumeIn = volumeTransferedToPerDayPerUser[i][user];
            volumes[i - startDay] = int256(volumeIn) - int256(volumeOut);
        }
        return volumes;
    }
}

interface IERC20 {
    function balanceOf(address user) external view returns (uint256);
}