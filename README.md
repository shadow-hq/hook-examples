## Shadow Hook Examples
This repository is a collection of shadow hook examples that demonstrates common patterns and may serve as an
inspiration for new developers.

## Overview

| Example | Description |
|---------|-------------|
| [rewards-dot-fun](./src/rewards-dot-fun) | Contracts for [rewards.fun]. Tracks points, multipliers and leaderboards based on live Base activity across multiple protocols |
| [transfer-volume](./src/transfer-volume) | Hook contract to track the volume of transfers for an ERC20 token |
| [wash-trades](./src/wash-trades) | Hook contract to track NFT wash trades. Uses hildobby's wash trade detection methods described [here](https://community.dune.com/blog/nft-wash-trading-on-ethereum) |
| [week-over-week-balances](./src/week-over-week-balances) | Hook contract to track the balances of users over time |

## Hook interface

### `on`
Registers a hook for a given event or trace call.

```solidity
/// @notice Registers a hook for a given event or function signature.
/// @param addr The address of the contract.
/// @param eventOrFunctionSignature The signature of the event or function to hook. e.g. `event Event(address,uint256)` or `function functionName(address,uint256)` The signature must be prefixed with `event` or `function`.
/// @param hookFunctionSignature The signature of the hook function. e.g. `onEvent` or `onFunction`
function on(address addr, string memory eventOrFunctionSignature, string memory hookFunctionSignature) external;
```

### `onEvent`
Registers a hook to handle an event emitted by a specific contract.
```solidity
/// @notice Registers an event hook for a given contract address.
/// @param addr The address of the contract.
/// @param eventSignature The signature of the event to hook. e.g. `Event(address,uint256)`
/// @param hookFunctionSignature The signature of the hook function. e.g. `onEvent`
function onEvent(address addr, string memory eventSignature, string memory hookFunctionSignature) external;
```

Registers a hook to handle an event emitted by any contract.

```solidity
/// @notice Registers an event hook for all contracts. The hook function will be called for all events with the given signature.
/// @param eventSignature The signature of the event to hook. e.g. `Event(address,uint256)`
/// @param hookFunctionSignature The signature of the hook function. e.g. `onEvent`
function onEvent(string memory eventSignature, string memory hookFunctionSignature) external;
```

### `onCall`
Registers a hook to handle trace calls to a specific contract.

```solidity
/// @notice Registers a call hook for a given contract address.
/// @param addr The address of the contract to hook.
/// @param functionSignature The signature of the function to hook. e.g. `functionName(address,uint256)`
/// @param hookFunctionSignature The signature of the hook function. e.g. `onFunction`
function onCall(address addr, string memory functionSignature, string memory hookFunctionSignature) external;
```

### `onSchedule`
Registers a hook to be run on a cron schedule.

```solidity
/// @notice Registers a cron hook.
/// @param cronExpression The cron expression to trigger the hook. e.g. `0 0 * * *` for midnight UTC every day.
/// @param hookFunctionSignature The signature of the hook function. e.g. `onCron`
function onSchedule(string memory cronExpression, string memory hookFunctionSignature) external;
```
