// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../../lib/shadow-std/Hook.sol";
import "../generated/GeneratedAerodrome.sol";
import "../Points.sol";

/// @notice Hooks for Aerodrome activity tracking.
contract Aerodrome is Hook {
    // Constants
    address private constant AERODROME_ROUTER = 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43;
    address private constant AERODROME_VOTING_ESCROW = 0xeBf418Fe2512e7E6bd9b87a8F0f294aCDC67e6B4;
    address private constant AERODROME_VOTER = 0x16613524e02ad97eDfeF371bC883F2F5d6C480A5;

    string private constant SIG_SWAP_EXACT_ETH_FOR_TOKENS =
        "swapExactETHForTokens(uint256 amountOutMin, Route[] routes, address to, uint256 deadline)";
    string private constant SIG_SWAP_EXACT_TOKENS_FOR_ETH =
        "swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, Route[] routes, address to, uint256 deadline)";
    string private constant SIG_ADD_LIQUIDITY =
        "addLiquidity(address tokenA, address tokenB, bool stable, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline)";
    string private constant SIG_ADD_LIQUIDITY_ETH =
        "addLiquidityETH(address token, bool stable, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline)";
    string private constant EVT_LOCK_PERMANENT =
        "LockPermanent(address indexed _owner, uint256 indexed _tokenId, uint256 amount, uint256 _ts)";
    string private constant EVT_VOTED =
        "Voted(address indexed voter, address indexed pool, uint256 indexed tokenId, uint256 weight, uint256 totalWeight, uint256 timestamp)";

    // State
    Points private immutable points;
    mapping(uint256 => address) private firstSwapOfTheDay;

    constructor(address pointsAddress) {
        points = Points(pointsAddress);

        // Registering call hooks
        vm.registerCallHook(AERODROME_ROUTER, SIG_SWAP_EXACT_ETH_FOR_TOKENS, "onSwapExactETHForTokens");
        vm.registerCallHook(AERODROME_ROUTER, SIG_SWAP_EXACT_TOKENS_FOR_ETH, "onSwapExactTokensForETH");
        vm.registerCallHook(AERODROME_ROUTER, SIG_ADD_LIQUIDITY, "onAddLiquidity");
        vm.registerCallHook(AERODROME_ROUTER, SIG_ADD_LIQUIDITY_ETH, "onAddLiquidityETH");

        // Registering event hooks
        vm.registerEventHook(AERODROME_VOTING_ESCROW, EVT_LOCK_PERMANENT, "onLockPermanent");
        vm.registerEventHook(AERODROME_VOTER, EVT_VOTED, "onVoted");
    }

    /// @notice Hook for a `swapExactETHForTokens` call.
    function onSwapExactETHForTokens(
        GeneratedAerodrome.SwapExactETHForTokensParams memory params,
        GeneratedAerodrome.SwapExactETHForTokensResult memory /* result */
    ) external {
        _onSwap(params.to);
    }

    /// @notice Hook for the `swapExactTokensForETH` call.
    function onSwapExactTokensForETH(
        GeneratedAerodrome.SwapExactTokensForETHParams memory params,
        GeneratedAerodrome.SwapExactTokensForETHResult memory /* result */
    ) external {
        _onSwap(params.to);
    }

    /// @dev Internal helper to handle swaps.
    function _onSwap(address to) internal {
        uint256 day = block.timestamp / 1 days;
        if (firstSwapOfTheDay[day] == address(0)) {
            // Use shadow contract state to track the first swap of the day.
            // If this is the first swap of the day, give 10 points.
            firstSwapOfTheDay[day] = to;
            points.increasePoints(Points.Protocol.AERODROME, to, 10);
            emit Points.PointsIncreased(Points.Protocol.AERODROME, "gmSwap", to, 10);
        } else {
            // Otherwise, give 1 point
            points.increasePoints(Points.Protocol.AERODROME, to, 1);
            emit Points.PointsIncreased(Points.Protocol.AERODROME, "swap", to, 1);
        }
    }

    /// @notice Hook for the `addLiquidity` call.
    function onAddLiquidity(
        GeneratedAerodrome.AddLiquidityParams memory params,
        GeneratedAerodrome.AddLiquidityResult memory /* result */
    ) external {
        points.increasePoints(Points.Protocol.AERODROME, params.to, 2);
        emit Points.PointsIncreased(Points.Protocol.AERODROME, "deposit", params.to, 2);
    }

    /// @notice Hook for the `addLiquidityETH` call.
    function onAddLiquidityETH(
        GeneratedAerodrome.AddLiquidityETHParams memory params,
        GeneratedAerodrome.AddLiquidityResult memory /* result */
    ) external {
        points.increasePoints(Points.Protocol.AERODROME, params.to, 2);
        emit Points.PointsIncreased(Points.Protocol.AERODROME, "deposit", params.to, 2);
    }

    /// @notice Hook for the `LockPermanent` event.
    function onLockPermanent(GeneratedAerodrome.LockPermanent memory evt) external {
        points.increasePoints(Points.Protocol.AERODROME, evt.owner, 100);
        emit Points.PointsIncreased(Points.Protocol.AERODROME, "lock", evt.owner, 100);
    }

    /// @notice Hook for the `Voted` event.
    function onVoted(GeneratedAerodrome.Voted memory evt) external {
        points.increasePoints(Points.Protocol.AERODROME, evt.voter, 10);
        emit Points.PointsIncreased(Points.Protocol.AERODROME, "vote", evt.voter, 10);
    }
}
