// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@shadow-std/Hook.sol";
import "@generated/WashTrades.gen.sol";

/// @notice Hook contract to track NFT wash trades. Uses hildobby's wash trade detection methods
/// described here https://community.dune.com/blog/nft-wash-trading-on-ethereum
contract WashTrades is Hook {
    // Events
    event ValidTransfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event WashTrade(address indexed user, uint256 indexed tokenId);

    // State
    address private immutable erc721;
    mapping(uint256 => WashTradesGenerated.Transfer[]) public transfersPerTokenId;

    constructor(address erc721Address) {
        // Register hook
        hook.on(erc721Address, "event Transfer(address,address,uint256)", "onTransfer");
    }

    /// @notice Hooks on the Transfer event. It emits a ValidTransfer event if the transfer is not a wash trade.
    /// Otherwise, it emits a WashTrade event.
    function onTransfer(WashTradesGenerated.Transfer memory evt) external {
        if (isWashTrade(evt)) {
            emit WashTrade(evt.from, evt.tokenId);
        } else {
            emit ValidTransfer(evt.from, evt.to, evt.tokenId);
        }
    }

    function isWashTrade(WashTradesGenerated.Transfer memory evt) internal view returns (bool) {
        if (evt.from == evt.to) {
            return true;
        }

        WashTradesGenerated.Transfer[] memory transferHistory = transfersPerTokenId[evt.tokenId];
        return isBackAndForth(transferHistory, evt) || didBuyOrSellMultipleTimes(transferHistory, evt);
    }

    function isBackAndForth(
        WashTradesGenerated.Transfer[] memory transferHistory,
        WashTradesGenerated.Transfer memory evt
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < transferHistory.length; i++) {
            if (transferHistory[i].from == evt.to && transferHistory[i].to == evt.from) {
                return true;
            }
        }
        return false;
    }

    function didBuyOrSellMultipleTimes(
        WashTradesGenerated.Transfer[] memory transferHistory,
        WashTradesGenerated.Transfer memory evt
    ) internal pure returns (bool) {
        uint256 buyCount = 0;
        uint256 sellCount = 0;
        for (uint256 i = 0; i < transferHistory.length; i++) {
            if (transferHistory[i].from == evt.from) {
                buyCount++;
            }
            if (transferHistory[i].to == evt.from) {
                sellCount++;
            }
        }
        return buyCount >= 3 || sellCount >= 3;
    }
}
