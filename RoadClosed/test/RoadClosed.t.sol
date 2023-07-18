// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/RoadClosed.sol";
import "../src/AttackContract.sol";

contract Hack is Test {
    RoadClosed public roadClosed;
    AttackContract public attackContract;
    address public owner = makeAddr("owner");
    address public hacker = makeAddr("hacker");

    function setUp() public {
        vm.createSelectFork(vm.envString("INFURA"));
        roadClosed = RoadClosed(0xD2372EB76C559586bE0745914e9538C17878E812);
    }

    function testHack() public {
        vm.startPrank(hacker);
        attackContract = new AttackContract(roadClosed, hacker);
        vm.stopPrank();
        assertEq(roadClosed.isHacked(), true);
    }
}
