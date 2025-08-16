// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TicketingSystem.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock MON Token for testing
contract MockMONToken is ERC20 {
    constructor() ERC20("MON Token", "MON") {
        _mint(msg.sender, 1000000 * 10**18); // Mint 1M tokens
    }
    
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TicketingSystemTest is Test {
    TicketingSystem public ticketingSystem;
    MockMONToken public monToken;
    
    address public owner;
    address public admin1;
    address public admin2;
    address public user1;
    address public user2;
    
    uint256 constant INITIAL_BALANCE = 10000 * 10**18; // 10K MON tokens
    
    function setUp() public {
        owner = address(this);
        admin1 = makeAddr("admin1");
        admin2 = makeAddr("admin2");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy mock MON token
        monToken = new MockMONToken();
        
        // Deploy ticketing system
        ticketingSystem = new TicketingSystem(address(monToken));
        
        // Mint tokens to users
        monToken.mint(user1, INITIAL_BALANCE);
        monToken.mint(user2, INITIAL_BALANCE);
        
        // Setup allowances
        vm.prank(user1);
        monToken.approve(address(ticketingSystem), type(uint256).max);
        
        vm.prank(user2);
        monToken.approve(address(ticketingSystem), type(uint256).max);
    }
    
    function testInitialSetup() public {
        // Test initial admin setup
        assertTrue(ticketingSystem.isAdmin(owner));
        assertEq(uint256(ticketingSystem.userRoles(owner)), uint256(TicketingSystem.UserRole.ADMIN));
        
        // Test MON token setup
        assertEq(address(ticketingSystem.monToken()), address(monToken));
        assertEq(monToken.balanceOf(user1), INITIAL_BALANCE);
        assertEq(monToken.balanceOf(user2), INITIAL_BALANCE);
    }
    
    function testAddRemoveAdmin() public {
        // Add admin
        ticketingSystem.addAdmin(admin1);
        assertTrue(ticketingSystem.isAdmin(admin1));
        assertEq(uint256(ticketingSystem.userRoles(admin1)), uint256(TicketingSystem.UserRole.ADMIN));
        
        // Remove admin
        ticketingSystem.removeAdmin(admin1);
        assertFalse(ticketingSystem.admins(admin1));
        assertEq(uint256(ticketingSystem.userRoles(admin1)), uint256(TicketingSystem.UserRole.USER));
        
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
        uint256 price = 100 * 10**18; // 100 MON
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
        uint256 ticketPrice = 100 * 10**18; // 100 MON
        ticketingSystem.createTicketType(1, "VIP", ticketPrice, 50);
        
        uint256 initialBalance = monToken.balanceOf(user1);
        uint256 initialContractBalance = monToken.balanceOf(address(ticketingSystem));
        
        // Purchase ticket
        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit TicketPurchased(1, 1, user1, ticketPrice);
        
        ticketingSystem.purchaseTicket(1);
        
        // Verify ticket data
        (
            uint256 ticketId,
            uint256 typeId,
            uint256 matchId,
            address ticketOwner,
            TicketingSystem.TicketStatus status,
            uint256 purchaseTime,
            uint256 price
        ) = ticketingSystem.tickets(1);
        
        assertEq(ticketId, 1);
        assertEq(typeId, 1);
        assertEq(matchId, 1);
        assertEq(ticketOwner, user1);
        assertEq(uint256(status), uint256(TicketingSystem.TicketStatus.SOLD));
        assertEq(purchaseTime, block.timestamp);
        assertEq(price, ticketPrice);
        
        // Verify balances
        assertEq(monToken.balanceOf(user1), initialBalance - ticketPrice);
        assertEq(monToken.balanceOf(address(ticketingSystem)), initialContractBalance + ticketPrice);
        
        // Verify sold count
        (, , , , , uint256 soldCount, ) = ticketingSystem.ticketTypes(1);
        assertEq(soldCount, 1);
    }
    
    function testRefundTicket() public {
        // Setup: create match, ticket type, and purchase ticket
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        uint256 ticketPrice = 100 * 10**18;
        ticketingSystem.createTicketType(1, "VIP", ticketPrice, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket(1);
        
        uint256 balanceBeforeRefund = monToken.balanceOf(user1);
        uint256 contractBalanceBeforeRefund = monToken.balanceOf(address(ticketingSystem));
        
        // Refund ticket
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit TicketRefunded(1, user1, ticketPrice);
        
        ticketingSystem.refundTicket(1);
        
        // Verify ticket status
        (, , , , TicketingSystem.TicketStatus status, , ) = ticketingSystem.tickets(1);
        assertEq(uint256(status), uint256(TicketingSystem.TicketStatus.REFUNDED));
        
        // Verify balances
        assertEq(monToken.balanceOf(user1), balanceBeforeRefund + ticketPrice);
        assertEq(monToken.balanceOf(address(ticketingSystem)), contractBalanceBeforeRefund - ticketPrice);
        
        // Verify sold count decreased
        (, , , , , uint256 soldCount, ) = ticketingSystem.ticketTypes(1);
        assertEq(soldCount, 0);
    }
    
    function testRefundTicketRestrictions() public {
        // Setup
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 3600, "Santiago Bernabeu"); // 1 hour from now
        ticketingSystem.createTicketType(1, "VIP", 100 * 10**18, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket(1);
        
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
        TicketingSystem.Match[] memory activeMatches = ticketingSystem.getActiveMatches();
        
        // Should return 2 active matches (1 and 3)
        assertEq(activeMatches.length, 2);
        assertEq(activeMatches[0].matchId, 1);
        assertEq(activeMatches[1].matchId, 3);
    }
    
    function testGetMatchTicketTypes() public {
        // Create match
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        
        // Create multiple ticket types
        ticketingSystem.createTicketType(1, "VIP", 200 * 10**18, 20);
        ticketingSystem.createTicketType(1, "Premium", 150 * 10**18, 50);
        ticketingSystem.createTicketType(1, "Regular", 100 * 10**18, 100);
        
        // Get ticket types for match
        TicketingSystem.TicketType[] memory ticketTypes = ticketingSystem.getMatchTicketTypes(1);
        
        assertEq(ticketTypes.length, 3);
        assertEq(ticketTypes[0].typeId, 1);
        assertEq(ticketTypes[1].typeId, 2);
        assertEq(ticketTypes[2].typeId, 3);
    }
    
    function testGetUserTickets() public {
        // Setup
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 100 * 10**18, 50);
        ticketingSystem.createTicketType(1, "Regular", 50 * 10**18, 100);
        
        // User1 purchases tickets
        vm.startPrank(user1);
        ticketingSystem.purchaseTicket(1);
        ticketingSystem.purchaseTicket(2);
        vm.stopPrank();
        
        // Get user tickets
        TicketingSystem.Ticket[] memory userTickets = ticketingSystem.getUserTickets(user1);
        
        assertEq(userTickets.length, 2);
        assertEq(userTickets[0].ticketId, 1);
        assertEq(userTickets[1].ticketId, 2);
        assertEq(userTickets[0].owner, user1);
        assertEq(userTickets[1].owner, user1);
    }
    
    function testWithdrawMON() public {
        // Setup: user purchases ticket to add funds to contract
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 100 * 10**18, 50);
        
        vm.prank(user1);
        ticketingSystem.purchaseTicket(1);
        
        uint256 contractBalance = ticketingSystem.getContractBalance();
        uint256 ownerBalanceBefore = monToken.balanceOf(owner);
        
        // Withdraw funds
        ticketingSystem.withdrawMON(contractBalance);
        
        assertEq(ticketingSystem.getContractBalance(), 0);
        assertEq(monToken.balanceOf(owner), ownerBalanceBefore + contractBalance);
    }
    
    function testInsufficientBalance() public {
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", INITIAL_BALANCE + 1, 50); // Price higher than user balance
        
        vm.prank(user1);
        vm.expectRevert("Insufficient MON token balance");
        ticketingSystem.purchaseTicket(1);
    }
    
    function testSoldOut() public {
        ticketingSystem.createMatch("Real Madrid", "Barcelona", block.timestamp + 7 days, "Santiago Bernabeu");
        ticketingSystem.createTicketType(1, "VIP", 100 * 10**18, 1); // Only 1 ticket
        
        // First purchase should succeed
        vm.prank(user1);
        ticketingSystem.purchaseTicket(1);
        
        // Second purchase should fail
        vm.prank(user2);
        vm.expectRevert("Tickets sold out");
        ticketingSystem.purchaseTicket(1);
    }
    
    // Event definitions for testing
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event MatchCreated(uint256 indexed matchId, string homeTeam, string awayTeam, uint256 matchTime);
    event TicketTypeCreated(uint256 indexed typeId, uint256 indexed matchId, string category, uint256 price, uint256 totalSupply);
    event TicketPurchased(uint256 indexed ticketId, uint256 indexed typeId, address indexed buyer, uint256 price);
    event TicketRefunded(uint256 indexed ticketId, address indexed owner, uint256 refundAmount);
    event MatchStatusChanged(uint256 indexed matchId, bool isActive);
}
