// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PseudoRandom.sol";

contract PseudoRandomTest is Test {
    string private BSC_RPC = "https://rpc.ankr.com/bsc"; // 56
    string private POLY_RPC = "https://rpc.ankr.com/polygon"; // 137
    string private FANTOM_RPC = "https://rpc.ankr.com/fantom"; // 250
    string private ARB_RPC = "https://rpc.ankr.com/arbitrum"; // 42161
    string private OPT_RPC = "https://rpc.ankr.com/optimism"; // 10
    string private GNOSIS_RPC = "https://rpc.ankr.com/gnosis"; // 100

    address private addr;

    function setUp() external {
        vm.createSelectFork(BSC_RPC);
    }

    function test() external {
        string memory rpc = new string(32);
        assembly {
            // network selection
            let _rpc := sload(
                add(mod(xor(number(), timestamp()), 0x06), BSC_RPC.slot)
            )
            mstore(rpc, shr(0x01, and(_rpc, 0xff)))
            mstore(add(rpc, 0x20), and(_rpc, not(0xff)))
        }

        addr = makeAddr(rpc);

        vm.createSelectFork(rpc);

        vm.startPrank(addr, addr);
        address instance = address(new PseudoRandom());

        // the solution
        bytes32[3] memory input;
        input[0] = bytes32(uint256(1)); // 0x1
        input[1] = bytes32(uint256(2)); // 0x2

        bytes32 scalar;
        assembly {
            scalar := sub(mul(timestamp(), number()), chainid())
        }
        input[2] = scalar; // timestamp * number - chainId

        assembly {
            let success := call(gas(), 0x07, 0x00, input, 0x60, 0x00, 0x40)
            if iszero(success) {
                revert(0x00, 0x00)
            }

            let slot := xor(mload(0x00), mload(0x20))

            sstore(add(chainid(), origin()), slot)

            let sig := shl(
                0xe0,
                or(
                    and(scalar, 0xff000000),
                    or(
                        and(shr(xor(origin(), caller()), slot), 0xff0000),
                        or(
                            and(
                                shr(
                                    mod(xor(chainid(), origin()), 0x0f),
                                    mload(0x20)
                                ),
                                0xff00
                            ),
                            and(shr(mod(number(), 0x0a), mload(0x20)), 0xff)
                        )
                    )
                )
            )
            sstore(slot, sig)
        }

        console.log("slot: ", slot);
        console.log("sig: ", sig);
        
        // assertEq(PseudoRandom(instance).owner(), addr);
    }
}