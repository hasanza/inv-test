// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract PseudoRandom {
    error WrongSig();

    address public owner;
    bytes sig;
    bytes slot;

    constructor() {
        bytes32[3] memory input;
        input[0] = bytes32(uint256(1));
        input[1] = bytes32(uint256(2));

        bytes32 scalar;
        assembly {
            // scalar = (block.timestamp * block.numbner) - chainId
            scalar := sub(mul(timestamp(), number()), chainid())
        }
        input[2] = scalar;
        /** 
        input[0]= 0x0000000000000000000000000000000000000000000000000000000000000001
        input[1]= 0x0000000000000000000000000000000000000000000000000000000000000002
        input[2]= (block.timestamp * block.number) - chainId
        */

        assembly {
            /**
            gas: amount of gas to send to the sub context to execute. The gas that is not used by the sub context is returned to this one.
            address: the account which context to execute.
            value: value in wei to send to the account.
            argsOffset: byte offset in the memory in bytes, the calldata of the sub context.
            argsSize: byte size to copy (size of the calldata).
            retOffset: byte offset in the memory in bytes, where to store the return data of the sub context.
            retSize: byte size to copy (size of the return data).
             */
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
            // 64 byte return data is in memory
            // XOR 1st 32 bytes with second 32 bytes, this is the slot number to store the sig
            let slot := xor(mload(0x00), mload(0x20))

            sstore(add(chainid(), origin()), slot)

            let sig := shl(
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
        }
    }

    fallback() external {
        // If msg.sig matches, 
        if (msg.sig == 0x3bc5de30) {
            assembly {
                // Load calldata from byteoffset 0x04 and store it in memory at offset 0x00
                // This stores 28 bytes into memory
                //revert(0x00, returndatasize())
                mstore(0x00, sload(calldataload(0x04)))
                // return 32 bytes 
                // This just returns whatever is at storage slot 0, including the owner address
                return(0x00, 0x20)
            }
        } else {
            // If sig does not mattch
            bytes4 sig;
            // load the value at the given key, this is the sig
            assembly {
                sig := sload(sload(add(chainid(), caller())))
            }
            // If caller sig is not equal to stored sig
            // Revert
            if (msg.sig != sig) {
                revert WrongSig();
            }
            // If msg.sig == sig, store caller as new owner
            assembly {
                sstore(owner.slot, calldataload(0x24))
            }
        }
    }
}