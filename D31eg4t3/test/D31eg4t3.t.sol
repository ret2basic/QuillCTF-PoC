// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/D31eg4t3.sol";
import "../src/AttackContract.sol";

contract CounterTest is Test {
    D31eg4t3 d31eg4t3;
    AttackContract attackContract;
    address hacker = makeAddr("hacker");

    function setUp() public {
        vm.createSelectFork(vm.envString("INFURA"));
        d31eg4t3 = D31eg4t3(0x971e55F02367DcDd1535A7faeD0a500B64f2742d);
        vm.prank(hacker);
        attackContract = new AttackContract(d31eg4t3);
    }

    function testHack() public {
        console.log("hacker's address: ", hacker); // 0xa63c492D8E9eDE5476CA377797Fe1dC90eEAE7fE
        vm.prank(hacker);
        attackContract.pwn();

        assertEq(d31eg4t3.owner(), hacker);
        assertEq(d31eg4t3.canYouHackMe(hacker), true);
    }
}
