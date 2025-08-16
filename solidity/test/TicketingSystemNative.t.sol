// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TicketingSystemNative.sol";

contract TicketingSystemNativeTest is Test {
    TicketingSystemNative public ticketingSystem;
    
    address public owner;
    address public admin1;
    address public admin2;
    address public user1;
    address public user2;
    
    uint256 constant INITIAL_BALANCE = 10 ether; // 10 MON
    
    function setUp() public {
        owner = address(this);
        admin1 = makeAddr("admin1");
        admin2 = makeAddr("admin2");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy ticketing system
        ticketingSystem = new TicketingSystemNative();
        
        // Give users some native MON tokens
        vm.deal(user1, INITIAL_BALANCE);
        vm.deal(user2, INITIAL_BALANCE);
        vm.deal(admin1, INITIAL_BALANCE);
    }
    
    function testInitialSetup() public {
        // Test initial admin setup
        assertTrue(ticketingSystem.isAdmin(owner));
        assertEq(uint256(ticketingSystem.userRoles(owner)), uint256(TicketingSystemNative.UserRole.ADMIN));
        
        // Test user balances
        assertEq(user1.balance, INITIAL_BALANCE);
        assertEq(user2.balance, INITIAL_BALANCE);
    }
    
    function testAddRemoveAdmin() public {
        // Add admin
        ticketingSystem.addAdmin(admin1);
        assertTrue(ticketingSystem.isAdmin(admin1));
        assertEq(uint256(ticketingSystem.userRoles(admin1)), uint256(TicketingSystemNative.UserRole.ADMIN));
        
        // Remove admin
        ticketingSystem.removeAdmin(admin1);
        assertFalse(ticketingSystem.admins(admin1));
        assertEq(uint256(ticketingSystem.userRoles(admin1)), uint256(TicketingSystemNative.UserRole.USER));
        
        // Test access control
        vm.prank(user1);
        vm.expectRevert();
        ticketingSystem.addAdmin(admin2);
    }
    
    function testCreateMatch() public {
        string memory homeTeam = "Real Madrid";
        string memory awayTeam = "Barcelona";
        uint256 matchTime = block.timestamp + 7 days;
        string memory venue = "Santiago Bernabeu";
        
        // Create match as admin
        vm.expectEmit(true, false, false, true);
        emit MatchCreated(1, homeTeam, awayTeam, matchTime);
        
        ticketingSystem.createMatch(homeTeam, awayTeam, matchTime, venue);
        
        // Verify match data
        (
            uint256 matchId,
            string memory storedHomeTeam,
            string memory storedAwayTeam,
            uint256 storedMatchTime,
            string memory storedVenue,
            bool isActive,
            uint256 createdAt
        ) = ticketingSystem.matches(1);
        
        assertEq(matchId, 1);
        assertEq(storedHomeTeam, homeTeam);
        assertEq(storedAwayTeam, awayTeam);
        assertEq(storedMatchTime, matchTime);
        assertEq(storedVenue, venue);
        assertTrue(isActive);
        assertEq(createdAt, block.timestamp);
    }
    
    function testCreateMatchAccessControl() public {
        vm.prank(user1);
        vm.expectRevert("Only admin can perform this action");
        ticketingSystem.createMatch("Team A", "Team B", block.timestamp + 1 days, "Stadium");
    }
    
    function testCreateTicketType() public {
        // First create a match
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        
        string memory category = "VIP";
        uint256 price = 1 ether; // 1 MON
        uint256 totalSupply = 50;
        
        // Create ticket type
        vm.expectEmit(true, true, false, true);
        emit TicketTypeCreated(1, 1, category, price, totalSupply);
        
        ticketingSystem.createTicketType(1, category, price, totalSupply);
        
        // Verify ticket type data
        (
            uint256 typeId,
            uint256 matchId,
            string memory storedCategory,
            uint256 storedPrice,
            uint256 storedTotalSupply,
            uint256 soldCount,
            bool isActive
        ) = ticketingSystem.ticketTypes(1);
        
        assertEq(typeId, 1);
        assertEq(matchId, 1);
        assertEq(storedCategory, category);
        assertEq(storedPrice, price);
        assertEq(storedTotalSupply, totalSupply);
        assertEq(soldCount, 0);
        assertTrue(isActive);
    }
    
    function testPurchaseTicket() public {
        // Setup: create match and ticket type
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        uint256 ticketPrice = 1 ether; // 1 MON
        ticketingSystem.createTicketType(1, "VIP", ticketPrice, 50);
        
        uint256 initialBalance = user1.balance;
        uint256 initialContractBalance = address(ticketingSystem).balance;
        
        // Purchase ticket
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user1, ticketPrice);
        
        ticketingSystem.purchaseTicket{value: ticketPrice}(1);
        
        // Verify ticket data
        (
            uint256 ticketId,
            uint256 typeId,
            uint256 matchId,
            address ticketOwner,
            TicketingSystemNative.TicketStatus status,
            uint256 purchaseTime,
            uint256 price
        ) = ticketingSystem.tickets(1);
        
        assertEq(ticketId, 1);
        assertEq(typeId, 1);
        assertEq(matchId, 1);
        assertEq(ticketOwner, user1);
        assertEq(uint256(status), uint256(TicketingSystemNative.TicketStatus.SOLD));
        assertEq(purchaseTime, block.timestamp);
        assertEq(price, ticketPrice);
        
        // Verify balances
        assertEq(user1.balance, initialBalance - ticketPrice);
        assertEq(address(ticketingSystem).balance, initialContractBalance + ticketPrice);
        
        // Verify sold count
        (, , , , , uint256 soldCount, ) = ticketingSystem.ticketTypes(1);
        assertEq(soldCount, 1);
    }
    
    function testPurchaseTicketWithExtraValue() public {
        // Setup
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        uint256 ticketPrice = 1 ether;
        ticketingSystem.createTicketType(1, "VIP", ticketPrice, 50);
        
        uint256 initialBalance = user1.balance;
        uint256 extraAmount = 0.5 ether;
        uint256 totalSent = ticketPrice + extraAmount;
        
        // Purchase ticket with extra value
        vm.prank(user1);
        ticketingSystem.purchaseTicket{value: totalSent}(1);
        
        // Should refund the extra amount
        assertEq(user1.balance, initialBalance - ticketPrice);
        assertEq(address(ticketingSystem).balance, ticketPrice);
    }
    
    function testRefundTicket() public {
        // Setup: create match, ticket type, and purchase ticket
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        uint256 ticketPrice = 1 ether;
        ticketingSystem.createTicketType(1, "VIP", ticketPrice, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket{value: ticketPrice}(1);
        
        uint256 balanceBeforeRefund = user1.balance;
        uint256 contractBalanceBeforeRefund = address(ticketingSystem).balance;
        
        // Refund ticket
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit TicketRefunded(1, user1, ticketPrice);
        
        ticketingSystem.refundTicket(1);
        
        // Verify ticket status
        (, , , , TicketingSystemNative.TicketStatus status, , ) = ticketingSystem.tickets(1);
        assertEq(uint256(status), uint256(TicketingSystemNative.TicketStatus.REFUNDED));
        
        // Verify balances
        assertEq(user1.balance, balanceBeforeRefund + ticketPrice);
        assertEq(address(ticketingSystem).balance, contractBalanceBeforeRefund - ticketPrice);
        
        // Verify sold count decreased
        (, , , , , uint256 soldCount, ) = ticketingSystem.ticketTypes(1);
        assertEq(soldCount, 0);
    }
    
    function testRefundTicketRestrictions() public {
        // Setup - match in 1 hour
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 3600, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 1 ether, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket{value: 1 ether}(1);
        
        // Try to refund ticket too close to match time
        vm.prank(user1);
        vm.expectRevert("Cannot refund within 1 hour of match time");
        ticketingSystem.refundTicket(1);
        
        // Test unauthorized refund
        vm.prank(user2);
        vm.expectRevert("You don't own this ticket");
        ticketingSystem.refundTicket(1);
    }
    
    function testGetActiveMatches() public {
        // Create multiple matches
        ticketingSystem.createMatch("Team A", "Team B", block.timestamp + 1 days, "Stadium A");
        ticketingSystem.createMatch("Team C", "Team D", block.timestamp + 2 days, "Stadium B");
        ticketingSystem.createMatch("Team E", "Team F", block.timestamp + 3 days, "Stadium C");
        
        // Deactivate one match
        ticketingSystem.setMatchStatus(2, false);
        
        // Get active matches
        TicketingSystemNative.Match[] memory activeMatches = ticketingSystem.getActiveMatches();
        
        // Should return 2 active matches (1 and 3)
        assertEq(activeMatches.length, 2);
        assertEq(activeMatches[0].matchId, 1);
        assertEq(activeMatches[1].matchId, 3);
    }
    
    function testGetMatchTicketTypes() public {
        // Create match
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        
        // Create multiple ticket types
        ticketingSystem.createTicketType(1, "VIP", 2 ether, 20);
        ticketingSystem.createTicketType(1, "Premium", 1.5 ether, 50);
        ticketingSystem.createTicketType(1, "Regular", 1 ether, 100);
        
        // Get ticket types for match
        TicketingSystemNative.TicketType[] memory ticketTypes = ticketingSystem.getMatchTicketTypes(1);
        
        assertEq(ticketTypes.length, 3);
        assertEq(ticketTypes[0].typeId, 1);
        assertEq(ticketTypes[1].typeId, 2);
        assertEq(ticketTypes[2].typeId, 3);
    }
    
    function testGetUserTickets() public {
        // Setup
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 2 ether, 50);
        ticketingSystem.createTicketType(1, "Regular", 1 ether, 100);
        
        // User1 purchases tickets
        vm.startPrank(user1);
        ticketingSystem.purchaseTicket{value: 2 ether}(1);
        ticketingSystem.purchaseTicket{value: 1 ether}(2);
        vm.stopPrank();
        
        // Get user tickets
        TicketingSystemNative.Ticket[] memory userTickets = ticketingSystem.getUserTickets(user1);
        
        assertEq(userTickets.length, 2);
        assertEq(userTickets[0].ticketId, 1);
        assertEq(userTickets[1].ticketId, 2);
        assertEq(userTickets[0].owner, user1);
        assertEq(userTickets[1].owner, user1);
    }
    
    function testWithdrawMON() public {
        // Setup: user purchases ticket to add funds to contract
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 1 ether, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket{value: 1 ether}(1);
        
        uint256 contractBalance = ticketingSystem.getContractBalance();
        uint256 ownerBalanceBefore = address(this).balance;
        
        // Withdraw funds
        ticketingSystem.withdrawMON(contractBalance);
        
        assertEq(ticketingSystem.getContractBalance(), 0);
        assertEq(address(this).balance, ownerBalanceBefore + contractBalance);
    }
    
    function testEmergencyWithdraw() public {
        // Setup: user purchases ticket
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 1 ether, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket{value: 1 ether}(1);
        
        uint256 contractBalance = address(ticketingSystem).balance;
        uint256 ownerBalanceBefore = address(this).balance;
        
        // Emergency withdraw
        ticketingSystem.emergencyWithdraw();
        
        assertEq(address(ticketingSystem).balance, 0);
        assertEq(address(this).balance, ownerBalanceBefore + contractBalance);
    }
    
    function testInsufficientValue() public {
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 1 ether, 50);
        
        vm.prank(user1);
        vm.expectRevert("Insufficient MON sent");
        ticketingSystem.purchaseTicket{value: 0.5 ether}(1); // Send less than required
    }
    
    function testSoldOut() public {
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 1 ether, 1); // Only 1 ticket
        
        // First purchase should succeed
        vm.prank(user1);
        ticketingSystem.purchaseTicket{value: 1 ether}(1);
        
        // Second purchase should fail
        vm.prank(user2);
        vm.expectRevert("Tickets sold out");
        ticketingSystem.purchaseTicket{value: 1 ether}(1);
    }
    
    function testReceiveFunction() public {
        uint256 initialBalance = address(ticketingSystem).balance;
        
        // Send MON directly to contract
        vm.prank(user1);
        (bool success, ) = address(ticketingSystem).call{value: 1 ether}("");
        assertTrue(success);
        
        assertEq(address(ticketingSystem).balance, initialBalance + 1 ether);
    }
    
    // Allow test contract to receive native tokens
    receive() external payable {}
    
    // Event definitions for testing
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event MatchCreated(uint256 indexed matchId, string homeTeam, string awayTeam, uint256 matchTime);
    event TicketTypeCreated(uint256 indexed typeId, uint256 indexed matchId, string category, uint256 price, uint256 totalSupply);
    event TicketPurchased(uint256 indexed ticketId, uint256 indexed typeId, address indexed buyer, uint256 price);
    event TicketRefunded(uint256 indexed ticketId, address indexed owner, uint256 refundAmount);
    event MatchStatusChanged(uint256 indexed matchId, bool isActive);
}
