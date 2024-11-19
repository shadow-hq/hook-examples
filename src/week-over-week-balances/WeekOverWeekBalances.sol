// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@shadow-std/Hook.sol";
import "@generated/WeekOverWeekBalances.gen.sol";

/// @notice Hook contract to track the balances of users over time.
contract WeekOverWeekBalances is Hook {
    IERC20 private immutable erc20;
    mapping(uint256 => mapping(address => uint256)) public balancesPerDay;

    constructor(address erc20Address) {
        erc20 = IERC20(erc20Address);

        // Register hook
        hook.on(erc20Address, "event Transfer(address,address,uint256)", "onTransfer");
    }

    /// @notice Hooks on the Transfer event of the ERC20 to track daily balances.
    function onTransfer(WeekOverWeekBalancesGenerated.Transfer memory evt) external {
        uint256 currentDay = block.timestamp / (60 * 60 * 24);
        uint256 currentBalance = erc20.balanceOf(evt.to);

        // Store the latest balance of the user
        balancesPerDay[currentDay][evt.to] = currentBalance;
    }

    /// @notice Gets the week over week balance changes for a user for a date range.
    /// @param user The user address.
    /// @param startTimestamp The start timestamp (inclusive).
    /// @param endTimestamp The end timestamp (inclusive).
    /// @return changes An array of balance changes for the user between the two days.
    function getWeekOverWeekBalanceChanges(address user, uint256 startTimestamp, uint256 endTimestamp)
        external
        view
        returns (int256[] memory)
    {
        // Round down to the nearest day
        uint256 startDay = startTimestamp / (60 * 60 * 24);
        uint256 endDay = endTimestamp / (60 * 60 * 24);

        // Calculate the WoW balance changes for the date range
        int256[] memory changes = new int256[](endDay - startDay + 1);
        for (uint256 i = startDay; i <= endDay; i++) {
            uint256 balanceForDay = getBalanceAtDay(user, i);

            uint256 sevenDaysAgo = i - (60 * 60 * 24 * 7);
            uint256 balance7DaysAgo = getBalanceAtDay(user, sevenDaysAgo);

            int256 change = int256(balanceForDay) - int256(balance7DaysAgo);

            changes[i - startDay] = change;
        }

        return changes;
    }

    function getBalanceAtDay(address user, uint256 day) internal view returns (uint256) {
        // If there is a balance for the exact day, just return it
        uint256 balance = balancesPerDay[day][user];
        if (balance > 0) {
            return balance;
        }
        // If not, then the balance is the balance of the last day with a balance
        for (uint256 i = day - 1; i > 0; i--) {
            balance = balancesPerDay[i][user];
            if (balance > 0) {
                return balance;
            }
        }
        return 0;
    }
}

interface IERC20 {
    function balanceOf(address user) external view returns (uint256);
}
