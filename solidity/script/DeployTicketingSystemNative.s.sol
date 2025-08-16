// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TicketingSystemNative.sol";

contract DeployTicketingSystemNative is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        TicketingSystemNative ticketingSystem = new TicketingSystemNative();
        
        console.log("TicketingSystemNative deployed to:", address(ticketingSystem));
        console.log("Deployer (Owner/Admin):", vm.addr(deployerPrivateKey));
        console.log("Contract supports native MON tokens");
        
        vm.stopBroadcast();
    }
}
