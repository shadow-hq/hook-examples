// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Aerodrome} from "../../src/rewards-dot-fun/Aerodrome.sol";
import {Points} from "../../src/rewards-dot-fun/Points.sol";
import {AerodromeGenerated} from "@generated/Aerodrome.gen.sol";
import {MockHookVm} from "@shadow-std/MockHookVm.sol";

contract AerodromeTest is Test {
    Points public points;
    Aerodrome public aerodrome;

    function setUp() public {
        MockHookVm hookVm = new MockHookVm();
        bytes memory code = address(hookVm).code;
        address targetAddr = address(uint160(uint256(keccak256("shadow cheatcodes"))));
        vm.etch(targetAddr, code);

        // Deploy the points contract
        points = new Points();

        // Deploy the aerodrome contract
        aerodrome = new Aerodrome(address(points));
    }

    function test_onSwapExactETHForTokens() public {
        AerodromeGenerated.Route memory route;
        route.from = address(0);
        route.to = address(1);
        route.stable = false;
        route.factory = address(2);

        AerodromeGenerated.SwapExactETHForTokensParams memory params;
        params.amountOutMin = 0;
        params.routes = new AerodromeGenerated.Route[](1);
        params.routes[0] = route;
        params.to = address(1);
        params.deadline = block.timestamp + 1 days;

        AerodromeGenerated.SwapExactETHForTokensResult memory result;

        // First swap
        vm.expectEmit(address(aerodrome));
        emit Points.PointsIncreased(Points.Protocol.AERODROME, "gmSwap", address(1), 10);

        aerodrome.onSwapExactETHForTokens(params, result);

        // Second swap
        vm.expectEmit(address(aerodrome));
        emit Points.PointsIncreased(Points.Protocol.AERODROME, "swap", address(1), 1);

        aerodrome.onSwapExactETHForTokens(params, result);
    }
}
