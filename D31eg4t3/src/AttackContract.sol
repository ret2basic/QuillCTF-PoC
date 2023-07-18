// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AttackContract{
    uint a = 12345;
    uint8 b = 32;
    string private d; 
    uint32 private c; 
    string private mot;
    address public owner;
    mapping (address => bool) public canYouHackMe;

    function updateOwner() public {
        owner = msg.sender;
    }

    function hacked() public onlyOwner{
        canYouHackMe[msg.sender] = true;
    }
}