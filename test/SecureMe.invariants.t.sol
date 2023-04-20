// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../src/SecureMe.sol";
import "../src/Handler.sol";

contract SecureMeInvariantTest is Test {
    SecureMe public instance;
    Handler public handler;

    function setUp() public {

        instance = new SecureMe();
        handler = new Handler(instance);
        // Constrain fuzz calls to the handler contract only
        targetContract(address(handler));
        // Mint ETH to this contract so ETH can be sent in fuzz calls
        deal(address(this), 100_000 ether);
    }

    function invariant_ETH_TOKEN_Parity() public {
        // SMTK SUPPLY == ETH BALANCE ALWAYS
        uint256 ethBal = address(instance).balance;
        uint256 SMTKSupply = instance.totalSupply();
        assertEq(ethBal, SMTKSupply);
    }
    

}

