// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/D31eg4t3.sol";
import "../src/AttackContract.sol";

contract CounterTest is Test {
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");
    D31eg4t3 d31eg4t3;
    AttackContract attackContract;

    function setUp() public {
        vm.startPrank(owner);
        d31eg4t3 = new D31eg4t3();
        vm.stopPrank();
    }

    function testHack() public {
        vm.startPrank(hacker);
        attackContract = new AttackContract();
        bytes data = keccak256(bytes("hacked()"));
        // d31eg4t3.hackMe(data);
        d31eg4t3.hacked();
    }
}
