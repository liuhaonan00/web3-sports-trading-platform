// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TicketingSystemNative.sol";

/**
 * @title DemoNative Script
 * @dev 演示原生MON代币智能合约功能的脚本
 * 包括部署、创建赛事、设置门票类型、购买和退票的完整流程
 */
contract DemoNative is Script {
    TicketingSystemNative public ticketingSystem;
    
    address public admin;
    address public user;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(deployerPrivateKey);
        
        // 为演示创建一个用户地址
        user = makeAddr("demo_user");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== Native MON Football Ticketing System Demo ===");
        console.log("Admin Address:", admin);
        console.log("User Address:", user);
        
        // 1. Deploy ticketing system
        console.log("\n1. Deploying ticketing system...");
        ticketingSystem = new TicketingSystemNative();
        console.log("TicketingSystemNative deployed at:", address(ticketingSystem));
        
        // 2. Give user some native MON for testing
        console.log("\n2. Setting up user with native MON...");
        vm.deal(user, 10 ether); // Give user 10 MON
        console.log("User now has 10 MON for testing");
        
        // 3. Create football match
        console.log("\n3. Creating football match...");
        ticketingSystem.createMatch(
            "Real Madrid",
            "Barcelona",
            block.timestamp + 7 days,
            "Santiago Bernabeu"
        );
        console.log("Created match: Real Madrid vs Barcelona");
        
        // 4. Create ticket types
        console.log("\n4. Creating ticket types...");
        
        // VIP tickets - 2 MON
        ticketingSystem.createTicketType(
            1, // matchId
            "VIP",
            2 ether, // 2 MON
            50 // 50 tickets
        );
        console.log("Created VIP tickets: 2 MON, 50 available");
        
        // Regular tickets - 1 MON
        ticketingSystem.createTicketType(
            1, // matchId
            "Regular",
            1 ether, // 1 MON
            200 // 200 tickets
        );
        console.log("Created Regular tickets: 1 MON, 200 available");
        
        // Stand tickets - 0.5 MON
        ticketingSystem.createTicketType(
            1, // matchId
            "Stand",
            0.5 ether, // 0.5 MON
            500 // 500 tickets
        );
        console.log("Created Stand tickets: 0.5 MON, 500 available");
        
        vm.stopBroadcast();
        
        // 5. Simulate user purchasing tickets
        console.log("\n5. Simulating user ticket purchases...");
        vm.startPrank(user);
        
        // Purchase VIP ticket
        ticketingSystem.purchaseTicket{value: 2 ether}(1);
        console.log("User purchased VIP ticket for 2 MON");
        
        // Purchase Regular ticket
        ticketingSystem.purchaseTicket{value: 1 ether}(2);
        console.log("User purchased Regular ticket for 1 MON");
        
        vm.stopPrank();
        
        // 6. Query user tickets
        console.log("\n6. Querying user tickets...");
        TicketingSystemNative.Ticket[] memory userTickets = ticketingSystem.getUserTickets(user);
        console.log("User has", userTickets.length, "tickets");
        
        for (uint i = 0; i < userTickets.length; i++) {
            console.log("Ticket ID:", userTickets[i].ticketId);
            console.log("Type ID:", userTickets[i].typeId);
            console.log("Price:", userTickets[i].price / 1 ether, "MON");
        }
        
        // 7. Query match info
        console.log("\n7. Querying match info...");
        TicketingSystemNative.Match[] memory matches = ticketingSystem.getActiveMatches();
        console.log("Active matches:", matches.length);
        
        if (matches.length > 0) {
            console.log("Match:", matches[0].homeTeam, "vs", matches[0].awayTeam);
            console.log("Venue:", matches[0].venue);
        }
        
        // 8. Query ticket types
        console.log("\n8. Querying ticket types...");
        TicketingSystemNative.TicketType[] memory ticketTypes = ticketingSystem.getMatchTicketTypes(1);
        console.log("Ticket types for match 1:", ticketTypes.length);
        
        for (uint i = 0; i < ticketTypes.length; i++) {
            console.log("Category:", ticketTypes[i].category);
            console.log("Price:", ticketTypes[i].price / 1 ether, "MON");
            console.log("Available:", ticketTypes[i].totalSupply - ticketTypes[i].soldCount);
        }
        
        // 9. Simulate refund
        console.log("\n9. Simulating refund...");
        vm.prank(user);
        ticketingSystem.refundTicket(1); // Refund VIP ticket
        console.log("User refunded VIP ticket");
        
        // 10. Final status
        console.log("\n10. Final status...");
        console.log("User MON balance:", user.balance / 1 ether, "MON");
        console.log("Contract MON balance:", ticketingSystem.getContractBalance() / 1 ether, "MON");
        
        TicketingSystemNative.Ticket[] memory finalTickets = ticketingSystem.getUserTickets(user);
        console.log("User final tickets:", finalTickets.length);
        
        console.log("\n=== Demo Complete ===");
        console.log("Contract Address:", address(ticketingSystem));
        console.log("Use this address with: ./interact_native.sh", address(ticketingSystem));
    }
}
