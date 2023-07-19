// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/safeNFT.sol";
import "../src/AttackContract.sol";

contract Hack is Test {
    safeNFT public nft;
    AttackContract public attackContract;
    address public hacker;
    
    function setUp() public {
        vm.createSelectFork(vm.envString("INFURA"));
        nft = safeNFT(0xf0337Cde99638F8087c670c80a57d470134C3AAE);
        vm.deal(hacker, 0.01 ether);
        vm.prank(hacker);
        attackContract = new AttackContract(nft);
    }

    function testHack() public {
        vm.prank(hacker);
        attackContract.pwn{value: 0.01 ether}();
    }
}
