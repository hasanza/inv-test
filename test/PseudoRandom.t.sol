// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {console} from "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/PseudoRandom.sol";

contract PseudoRandomTest is Test {
    PseudoRandom public instance;

    function setUp() public {
        console.log("Testing...");
        instance = new PseudoRandom();
    }

    function test_makeCall() public {
        // Make call with sig: 0x3bc5de30
        // Call the function get data
        (bool success, bytes memory res) = address(instance).call{value: 0}(abi.encodeWithSignature("getData()"));
        console.logBytes(res);
        
    }

    function test_sigCalc() public returns (bytes memory data) {
    bytes32[3] memory input;
    bytes memory sig;
    bytes memory slot;
        input[0] = bytes32(uint256(1));
        input[1] = bytes32(uint256(2));

        bytes32 scalar;
        assembly {
            // scalar = (block.timestamp * block.numbner) - chainId
            scalar := sub(mul(timestamp(), number()), chainid())
        }
        input[2] = scalar;
        assembly {
            let success := call(
                gas(), // Send remaining gas
                0x07, // call 0x07?
                0x00, // Send 0 wei
                input, // starting index of the arg array in memory
                0x60, // arg size; 96 bytes
                0x00, // mem offset to store the returned data
                0x40)   // size of return data; 64 bytes
            if iszero(success) {
                revert(0x00, 0x00)
            }
            // 64 bite return data is in memory
            // XOR 1st 32 bytes with second 32 bytes, this is the slot number to store the sig
            slot := xor(mload(0x00), mload(0x20))

            scalar := sub(mul(timestamp(), number()), chainid())
            sig := shl(
                0xe0, //224, so shift left 224 bits (256-32=224). Of what? Of the next arg
                or(
                    and(scalar, 0xff000000),// Perform bitwise AND on first 4 bytes of the SIG
                    or( // OR this with,
                        and(shr(xor(origin(), caller()), slot), 0xff0000), // 
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
            mstore(0x00, slot)
            mstore(0x20, sig)
            return(0x00, 0x40)
        }

    }
}
