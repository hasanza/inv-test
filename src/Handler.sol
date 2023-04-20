// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import "../src/SecureMe.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    SecureMe public instance;

    // Passing in the contract to invariant test
    constructor(SecureMe secureMe) {
        instance = secureMe;
    }

    function mint(address to, uint256 amount) public {
        instance.mint(to, amount);
        
    }
    function deposit(uint256 amount) public {
        instance.deposit{value: amount}();
    }

    // Function to deposit ETH directly into our contract
    function directDepositETH(uint256 amount) public {
        (bool success, bytes memory res) = address(instance).call{
            value: amount
        }("");
        require(success);
    }

    // View functions
    function tokenSupply() public view returns (uint256) {
        return instance.totalSupply();
    }

    function ethBal() public view returns (uint256) {
        return address(instance).balance;
    }

    fallback() external payable {
    }

}
