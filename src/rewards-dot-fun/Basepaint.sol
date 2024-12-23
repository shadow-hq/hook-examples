// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@shadow-std/Hook.sol";
import "@generated/Basepaint.gen.sol";
import "./Points.sol";

/// @notice Hooks for Basepaint activity tracking.
contract Basepaint is Hook {
    // Constants
    address private constant BASEPAINT = 0xBa5e05cb26b78eDa3A2f8e3b3814726305dcAc83;
    address private constant BASEPAINT_REWARDS = 0xaff1A9E200000061fC3283455d8B0C7e3e728161;
    address private constant BASEPAINT_ANIMATION = 0xC59F475122e914aFCf31C0a9E0A2274666135e4E;

    string private constant EVT_PAINTED =
        "event Painted(uint256 indexed day, uint256 tokenId, address author, bytes pixels)";

    string private constant FN_MINT =
        "function mint(uint256 tokenId, address sendMintsTo, uint256 count, address sendRewardsTo)";
    string private constant FN_ANIMATED_MINT =
        "function onERC1155Received(address, address from, uint256 id, uint256 value, bytes)";

    // State
    Points private immutable points;
    mapping(uint256 => address) private firstPaintOnCanvas;

    constructor(address pointsAddress) {
        points = Points(pointsAddress);

        // Event hooks
        hook.on(BASEPAINT, EVT_PAINTED, "onPainted");

        // Call hooks
        hook.on(BASEPAINT_REWARDS, FN_MINT, "onMint");
        hook.on(BASEPAINT_ANIMATION, FN_ANIMATED_MINT, "onAnimatedMint");
    }

    /// @notice Hook for the `Painted` event.
    function onPainted(BasepaintGenerated.Painted memory evt) external {
        uint256 numPixels = evt.pixels.length / 3;

        // Only give points for paintings with more than 99 pixels.
        if (numPixels > 99) {
            if (firstPaintOnCanvas[evt.tokenId] == address(0)) {
                // Use shadow contract state to track the first paint on a canvas.
                // Give 2500 points for the first paint on a canvas.
                firstPaintOnCanvas[evt.tokenId] = evt.author;
                points.increasePoints(Points.Protocol.BASEPAINT, evt.author, 2500);
                emit Points.PointsIncreased(Points.Protocol.BASEPAINT, "gmPaint", evt.author, 2500);
            } else {
                // Give 250 points for any subsequent paint on a canvas.
                points.increasePoints(Points.Protocol.BASEPAINT, evt.author, 250);
                emit Points.PointsIncreased(Points.Protocol.BASEPAINT, "paint", evt.author, 250);
            }
        }
    }

    /// @notice Hook for the `mint` call.
    function onMint(BasepaintGenerated.MintParams memory params) external {
        points.increasePoints(Points.Protocol.BASEPAINT, params.sendMintsTo, params.count * 3000);
        emit Points.PointsIncreased(Points.Protocol.BASEPAINT, "mint", params.sendMintsTo, params.count * 3000);
    }

    /// @notice Hook for the `onERC1155Received` call.
    function onAnimatedMint(
        BasepaintGenerated.OnERC1155ReceivedParams memory params,
        BasepaintGenerated.OnERC1155ReceivedResult memory /* result */
    ) external {
        points.increasePoints(Points.Protocol.BASEPAINT, params.from, 1000);
        emit Points.PointsIncreased(Points.Protocol.BASEPAINT, "animatedMint", params.from, 1000);
    }
}
