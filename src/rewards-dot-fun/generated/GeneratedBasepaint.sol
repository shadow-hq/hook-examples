// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// THIS FILE IS AUTOGENERATED. DO NOT EDIT.
library GeneratedBasepaint {
    struct MintParams {
        uint256 tokenId;
        address sendMintsTo;
        uint256 count;
        address sendRewardsTo;
    }

    struct Painted {
        uint256 day;
        uint256 tokenId;
        address author;
        bytes pixels;
    }

    struct OnERC1155ReceivedParams {
        address operator;
        address from;
        uint256 id;
        uint256 value;
        bytes data;
    }

    struct OnERC1155ReceivedResult {
        bytes4 value;
    }
}