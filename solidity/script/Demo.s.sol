// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TicketingSystem.sol";
import "../test/TicketingSystem.t.sol"; // For MockMONToken

/**
 * @title Demo Script
 * @dev 演示智能合约功能的脚本
 * 包括部署、创建赛事、设置门票类型、购买和退票的完整流程
 */
contract Demo is Script {
    TicketingSystem public ticketingSystem;
    MockMONToken public monToken;
    
    address public admin;
    address public user;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(deployerPrivateKey);
        
        // 为演示创建一个用户地址
        user = makeAddr("demo_user");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== 足球买票系统演示 ===");
        console.log("Admin Address:", admin);
        console.log("User Address:", user);
        
        // 1. 部署MON代币合约 (仅演示用)
        console.log("\n1. 部署MON代币...");
        monToken = new MockMONToken();
        console.log("MON Token deployed at:", address(monToken));
        
        // 2. 部署票务系统
        console.log("\n2. 部署票务系统...");
        ticketingSystem = new TicketingSystem(address(monToken));
        console.log("TicketingSystem deployed at:", address(ticketingSystem));
        
        // 3. 给用户分发MON代币
        console.log("\n3. 给用户分发MON代币...");
        monToken.mint(user, 1000 * 10**18); // 1000 MON
        console.log("Minted 1000 MON tokens to user");
        
        // 4. 创建足球赛事
        console.log("\n4. 创建足球赛事...");
        ticketingSystem.createMatch(
            "Real Madrid",
            "Barcelona",
            block.timestamp + 7 days,
            "Santiago Bernabeu"
        );
        console.log("Created match: Real Madrid vs Barcelona");
        
        // 5. 创建门票类型
        console.log("\n5. 创建门票类型...");
        
        // VIP门票
        ticketingSystem.createTicketType(
            1, // matchId
            "VIP",
            200 * 10**18, // 200 MON
            50 // 50张票
        );
        console.log("Created VIP tickets: 200 MON, 50 available");
        
        // 普通门票
        ticketingSystem.createTicketType(
            1, // matchId
            "Regular",
            100 * 10**18, // 100 MON
            200 // 200张票
        );
        console.log("Created Regular tickets: 100 MON, 200 available");
        
        // 看台门票
        ticketingSystem.createTicketType(
            1, // matchId
            "Stand",
            50 * 10**18, // 50 MON
            500 // 500张票
        );
        console.log("Created Stand tickets: 50 MON, 500 available");
        
        vm.stopBroadcast();
        
        // 6. 模拟用户购买门票
        console.log("\n6. 模拟用户购买门票...");
        vm.startPrank(user);
        
        // 授权MON代币
        monToken.approve(address(ticketingSystem), type(uint256).max);
        console.log("User approved MON tokens");
        
        // 购买VIP门票
        ticketingSystem.purchaseTicket(1); // VIP typeId
        console.log("User purchased VIP ticket");
        
        // 购买普通门票
        ticketingSystem.purchaseTicket(2); // Regular typeId
        console.log("User purchased Regular ticket");
        
        vm.stopPrank();
        
        // 7. 查询用户门票
        console.log("\n7. 查询用户门票...");
        TicketingSystem.Ticket[] memory userTickets = ticketingSystem.getUserTickets(user);
        console.log("User has", userTickets.length, "tickets");
        
        for (uint i = 0; i < userTickets.length; i++) {
            console.log("Ticket ID:", userTickets[i].ticketId);
            console.log("Type ID:", userTickets[i].typeId);
            console.log("Price:", userTickets[i].price / 10**18, "MON");
        }
        
        // 8. 查询赛事信息
        console.log("\n8. 查询赛事信息...");
        TicketingSystem.Match[] memory matches = ticketingSystem.getActiveMatches();
        console.log("Active matches:", matches.length);
        
        if (matches.length > 0) {
            console.log("Match:", matches[0].homeTeam, "vs", matches[0].awayTeam);
            console.log("Venue:", matches[0].venue);
        }
        
        // 9. 查询门票类型
        console.log("\n9. 查询门票类型...");
        TicketingSystem.TicketType[] memory ticketTypes = ticketingSystem.getMatchTicketTypes(1);
        console.log("Ticket types for match 1:", ticketTypes.length);
        
        for (uint i = 0; i < ticketTypes.length; i++) {
            console.log("Category:", ticketTypes[i].category);
            console.log("Price:", ticketTypes[i].price / 10**18, "MON");
            console.log("Available:", ticketTypes[i].totalSupply - ticketTypes[i].soldCount);
        }
        
        // 10. 模拟退票
        console.log("\n10. 模拟退票...");
        vm.prank(user);
        ticketingSystem.refundTicket(1); // 退VIP门票
        console.log("User refunded VIP ticket");
        
        // 11. 最终状态
        console.log("\n11. 最终状态...");
        console.log("User MON balance:", monToken.balanceOf(user) / 10**18, "MON");
        console.log("Contract MON balance:", ticketingSystem.getContractBalance() / 10**18, "MON");
        
        TicketingSystem.Ticket[] memory finalTickets = ticketingSystem.getUserTickets(user);
        console.log("User final tickets:", finalTickets.length);
        
        console.log("\n=== 演示完成 ===");
    }
}
