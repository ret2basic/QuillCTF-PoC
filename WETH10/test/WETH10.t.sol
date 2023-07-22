// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/WETH10.sol";
import "../src/AttackContract.sol";

contract Weth10Test is Test {
    WETH10 public weth;
    AttackContract public attackContract;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH10();
        bob = makeAddr("bob");

        vm.deal(address(weth), 10 ether);
        vm.deal(address(bob), 1 ether);
    }

    function testHack() public {
        assertEq(address(weth).balance, 10 ether, "weth contract should have 10 ether");

        vm.startPrank(bob);

        // hack time!
        // Deploy attackContract
        console.log("Bob's ETH balance at the very beginning: ", bob.balance / 10 ** 18, "ETH");
        console.log("Deploying attackContract and send 1 ETH to it.");
        attackContract = new AttackContract{value: 1 ether}(weth);
        console.log("attackContract's ETH balance: ", address(attackContract).balance / 10 ** 18, "ETH");

        console.log("Calling pwn().");
        attackContract.pwn();
        console.log("Bob's balance in the end: ", bob.balance / 10 ** 18, "ether");

        vm.stopPrank();
        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(bob.balance, 11 ether, "player should end with 11 ether");
    }
}
