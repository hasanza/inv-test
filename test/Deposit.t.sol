// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../src/SecureMe.sol";

contract DepositTest is Test {
    address public DAIAddr;
    uint256 mainnetFork;
    ERC20 DAI;
    address user;
    SecureMe instance;

    function setUp() public {
        // Create fork
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));
        // Select the fork to the next setup steps on
        vm.selectFork(mainnetFork);
        // User with a lot of DAI
        user = address(0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8);
        // The DAI contract address
        DAIAddr = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        // Compose the DAI contract instance using ERC20 interface
        DAI = ERC20(DAIAddr);
        // Instantiate SecureMe
        instance = new SecureMe();
        // Boostrap test contract w/ ETH
        deal(address(this), 100 ether);
        // Mint attacker 50_000 DAI
        deal(user, 100 ether);
    }

    function test_deposit() public {
        // Select the fork to run this test on
        vm.selectFork(mainnetFork);
        // Change msg.sender to `user` for all subsequent calls
        vm.startPrank(user);
        // Approve instance to transfer 500 DAI from user
        DAI.approve(address(instance), 500 ether);
        // Cache the allowance amount
        uint256 allowance = DAI.allowance(user, address(instance));
        // call depositDAI
        instance.depositDAI(500 ether);
        // Assert that minted tokens are equal to approved and deposited DAI
        assertEq(allowance, instance.balanceOf(user));
    }
}
