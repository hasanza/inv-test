// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Ownable} from "openzeppelin-contracts/contracts/Access/Ownable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
//import {FlashLoanRecipient} from "./FlashLoanRecipient.sol";
import "forge-std/Test.sol";

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

    function depositDAI(uint256 amount) external {
        ERC20 DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        // Require that the amount is non-zero and this contract has the required allowance
        require(amount != 0);
        require(DAI.allowance(msg.sender, address(this)) >= amount, "You must approve the transfer of DAI first");
        // Transfer amount of DAI from caller (the user) to this contract
        DAI.transferFrom(msg.sender, address(this), amount);
        // Mint same amount of SMTK tokens
        _mint(msg.sender, amount);

    }
    
    function daiBal() public view returns (uint256) {
        ERC20 DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        return DAI.balanceOf(address(this));
    }

    receive() external payable {}

    /// @notice Allows users to borrow flash loans
    // function flashLoan(FlashLoanRecipient recipient, uint256 amount) external {
    //     // Preloan balance of this contract - 50
    //     uint256 preLoanBalance = balanceOf(address(this));
    //     // Ensure contract has enough tokens for this amount of flashLoan
    //     require(preLoanBalance >= amount, "SecureMe: Not enough balance");
    //     // Transfer tokens to borrower
    //     require(
    //         IERC20(address(this)).transfer(address(recipient), amount),
    //         "SecureMe: Loan transfer failed"
    //     );

    //     console.log("Lender Balance after transfer", balanceOf(address(this)));
    //     console.log("Borrower Balance after transfer", balanceOf(address(recipient)));
    //     // Apparently owner repaus the 50, not the receiver contract for some reason
    //     // Invoke the callback on the receiver contract
    //     recipient.receiveFlashLoan(amount);

    //     uint256 postLoanBalance = balanceOf(address(this));
    //     require(
    //       // Ensure post loan balance is less or equal to pre loan
    //         postLoanBalance >= preLoanBalance,
    //         "SecureMe: Incomplete loan repayment"
    //     );
    // }


}
