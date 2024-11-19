// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./HookVm.sol";

abstract contract Hook {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("shadow cheatcodes"))));
    HookVm internal hook;

    constructor() {
        hook = HookVm(VM_ADDRESS);
    }
}
