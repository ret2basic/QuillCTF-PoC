// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./TrueXOR.sol";

contract AttackContract {
    function giveBool() external view returns (bool) {
        return gasleft() >= 6000;
    }
}