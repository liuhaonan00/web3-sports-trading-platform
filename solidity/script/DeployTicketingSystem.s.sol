// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TicketingSystem.sol";

contract DeployTicketingSystem is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Monad testnet MON token address (you'll need to replace this with the actual address)
        // For testing purposes, you might need to deploy a mock token first
        address monTokenAddress = vm.envAddress("MON_TOKEN_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        TicketingSystem ticketingSystem = new TicketingSystem(monTokenAddress);
        
        console.log("TicketingSystem deployed to:", address(ticketingSystem));
        console.log("MON Token address:", monTokenAddress);
        console.log("Deployer (Owner/Admin):", vm.addr(deployerPrivateKey));
        
        vm.stopBroadcast();
    }
}
