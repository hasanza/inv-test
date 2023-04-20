// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Ownable} from "openzeppelin-contracts/contracts/Access/Ownable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
//import {FlashLoanRecipient} from "./FlashLoanRecipient.sol";

contract SecureMe is ERC20, Ownable {
    constructor() ERC20("SecureMe", "SMTK") {}

    /// @notice mints SMTK tokens to users. Callable only by the owner
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function deposit() external payable {
        require(msg.value > 0, "SecureMe: Cannot deposit 0 ETH");
        _mint(msg.sender, msg.value);
    }

    receive() external payable {

    }

}
