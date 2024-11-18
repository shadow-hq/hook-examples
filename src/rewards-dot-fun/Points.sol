// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Points {
    // Types
    enum Protocol {
        AERODROME,
        AI_AGENTS,
        BASE,
        BASEPAINT,
        FRENPET,
        ZORA
    }

    // Events
    event PointsIncreased(Protocol protocol, string actionType, address user, uint256 amount);
    event MultiplierIncreased(address from, address to, uint256 oldMultiplier, uint256 newMultiplier);
    event MultiplierDecreased(address from, address to, uint256 oldMultiplier, uint256 newMultiplier);

    // State
    mapping(Protocol => mapping(uint256 => mapping(address => uint256))) public rawPoints;
    mapping(Protocol => mapping(uint256 => address[])) public participants;
    mapping(uint256 => mapping(address => uint256)) public multiplierCount;
    mapping(Protocol => mapping(uint256 => address[3])) public snapshottedLeaderboards;

    function snapshotLeaderboard() external {
        uint256 period = getCurrentPeriod();

        Protocol[6] memory protocols;
        protocols[0] = Protocol.AERODROME;
        protocols[1] = Protocol.AI_AGENTS;
        protocols[2] = Protocol.BASE;
        protocols[3] = Protocol.BASEPAINT;
        protocols[4] = Protocol.FRENPET;
        protocols[5] = Protocol.ZORA;

        for (uint256 i = 0; i < protocols.length; i++) {
            Protocol protocol = protocols[i];
            address[3] memory leaderboard = calculateLeaderboard(protocol, period);
            snapshottedLeaderboards[protocol][period] = leaderboard;
        }
    }

    function calculateLeaderboard(Protocol protocol, uint256 period) public view returns (address[3] memory) {
        address first = address(0);
        address second = address(0);
        address third = address(0);

        address[] storage arr = participants[protocol][period];
        for (uint256 i = 0; i < arr.length; i++) {
            address current = arr[i];

            if (current > first) {
                third = second;
                second = first;
                first = current;
            } else if (current > second) {
                third = second;
                second = current;
            } else if (current > third) {
                third = current;
            }
        }

        address[3] memory leaderboard;
        leaderboard[0] = first;
        leaderboard[1] = second;
        leaderboard[2] = third;

        return leaderboard;
    }

    function increasePoints(Protocol protocol, address user, uint256 amount) external {
        uint256 period = getCurrentPeriod();
        uint256 currentPoints = rawPoints[protocol][period][user];
        if (currentPoints == 0) {
            participants[protocol][period].push(user);
        }
        rawPoints[protocol][period][user] += amount;
    }

    function increaseMultiplier(address from, address to) external {
        uint256 period = getCurrentPeriod();
        uint256 oldMultiplier = calculateMultiplier(period, to);
        multiplierCount[period][to]++;
        uint256 newMultiplier = calculateMultiplier(period, to);
        emit MultiplierIncreased(from, to, oldMultiplier, newMultiplier);
    }

    function decreaseMultiplier(address from, address to) external {
        uint256 period = getCurrentPeriod();
        uint256 oldMultiplier = calculateMultiplier(period, to);
        multiplierCount[period][to]--;
        uint256 newMultiplier = calculateMultiplier(period, to);
        emit MultiplierDecreased(from, to, oldMultiplier, newMultiplier);
    }

    function getPoints(Protocol protocol, uint256 period, address user) public view returns (uint256) {
        return rawPoints[protocol][period][user] * calculateMultiplier(period, user);
    }

    function calculateMultiplier(uint256 period, address user) internal view returns (uint256) {
        uint256 count = multiplierCount[period][user] + 1;
        return 1 + 999 * (1 - 1 / (count + 1));
    }

    function getCurrentPeriod() internal view returns (uint256) {
        // Round down to the nearest day
        return block.timestamp / 86400;
    }
}
