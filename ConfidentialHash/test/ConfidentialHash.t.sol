// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/ConfidentialHash.sol";

contract Hack is Test {
    Confidential public confidentialHash;
    address public owner = makeAddr("owner");
    address public hacker = makeAddr("hakcer");

    function setUp() public {
        vm.createSelectFork(vm.envString("INFURA"));
        confidentialHash = Confidential(0xf8E9327E38Ceb39B1Ec3D26F5Fad09E426888E66);
    }

    function testHack() public {
        vm.startPrank(hacker);
        bytes32 hashedResult = confidentialHash.hash(
            bytes32(0x448e5df1a6908f8d17fae934d9ae3f0c63545235f8ff393c6777194cae281478),
            bytes32(0x98290e06bee00d6b6f34095a54c4087297e3285d457b140128c1c2f3b62a41bd)
        );
        vm.stopPrank();

        assertEq(confidentialHash.checkthehash(hashedResult), true);
    }
}
