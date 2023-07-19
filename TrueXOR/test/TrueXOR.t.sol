// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TrueXOR.sol";
import "../src/AttackContract.sol";

contract Hack is Test {
    TrueXOR public trueXOR;
    AttackContract public attackContract;
    address public owner;
    address public hacker;

    function setUp() public {
        owner = makeAddr("owner");
        hacker = makeAddr("hacker");
        vm.prank(owner);
        trueXOR = new TrueXOR();
        vm.prank(hacker);
        attackContract = new AttackContract();
    }

    function testHack() public {
        vm.prank(msg.sender);
        assertEq(trueXOR.callMe{gas: 10000}(address(attackContract)), true);
    }
}
