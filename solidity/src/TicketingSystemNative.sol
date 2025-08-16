// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TicketingSystemNative
 * @dev 足球赛事门票系统智能合约 - 支持原生MON代币
 * 支持管理员管理赛事和门票，用户使用原生MON代币购买和退票功能
 */
contract TicketingSystemNative is Ownable, ReentrancyGuard {
    
    // 用户角色枚举
    enum UserRole { USER, ADMIN }
    
    // 门票状态枚举
    enum TicketStatus { AVAILABLE, SOLD, REFUNDED }
    
    // 赛事信息结构体
    struct Match {
        uint256 matchId;
        string homeTeam;
        string awayTeam;
        uint256 matchTime;
        string venue;
        bool isActive;
        uint256 createdAt;
    }
    
    // 门票类型结构体
    struct TicketType {
        uint256 typeId;
        uint256 matchId;
        string category; // VIP, 普通席, 看台等
        uint256 price; // 以原生MON代币为单位 (wei)
        uint256 totalSupply;
        uint256 soldCount;
        bool isActive;
    }
    
    // 门票信息结构体
    struct Ticket {
        uint256 ticketId;
        uint256 typeId;
        uint256 matchId;
        address owner;
        TicketStatus status;
        uint256 purchaseTime;
        uint256 price;
    }
    
    // 状态变量
    mapping(address => UserRole) public userRoles;
    mapping(uint256 => Match) public matches;
    mapping(uint256 => TicketType) public ticketTypes;
    mapping(uint256 => Ticket) public tickets;
    mapping(address => uint256[]) public userTickets;
    
    uint256 public nextMatchId = 1;
    uint256 public nextTypeId = 1;
    uint256 public nextTicketId = 1;
    
    // 管理员地址列表
    mapping(address => bool) public admins;
    
    // 事件定义
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event MatchCreated(uint256 indexed matchId, string homeTeam, string awayTeam, uint256 matchTime);
    event TicketTypeCreated(uint256 indexed typeId, uint256 indexed matchId, string category, uint256 price, uint256 totalSupply);
    event TicketPurchased(uint256 indexed ticketId, uint256 indexed typeId, address indexed buyer, uint256 price);
    event TicketRefunded(uint256 indexed ticketId, address indexed owner, uint256 refundAmount);
    event MatchStatusChanged(uint256 indexed matchId, bool isActive);
    
    // 修饰符
    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner(), "Only admin can perform this action");
        _;
    }
    
    modifier validMatch(uint256 _matchId) {
        require(_matchId > 0 && _matchId < nextMatchId, "Invalid match ID");
        require(matches[_matchId].isActive, "Match is not active");
        _;
    }
    
    modifier validTicketType(uint256 _typeId) {
        require(_typeId > 0 && _typeId < nextTypeId, "Invalid ticket type ID");
        require(ticketTypes[_typeId].isActive, "Ticket type is not active");
        _;
    }
    
    /**
     * @dev 构造函数
     */
    constructor() Ownable(msg.sender) {
        // 将部署者设置为第一个管理员
        admins[msg.sender] = true;
        userRoles[msg.sender] = UserRole.ADMIN;
        emit AdminAdded(msg.sender);
    }
    
    /**
     * @dev 添加管理员
     * @param _admin 新管理员地址
     */
    function addAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Invalid admin address");
        require(!admins[_admin], "Address is already an admin");
        
        admins[_admin] = true;
        userRoles[_admin] = UserRole.ADMIN;
        emit AdminAdded(_admin);
    }
    
    /**
     * @dev 移除管理员
     * @param _admin 要移除的管理员地址
     */
    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Invalid admin address");
        require(admins[_admin], "Address is not an admin");
        require(_admin != owner(), "Cannot remove contract owner");
        
        admins[_admin] = false;
        userRoles[_admin] = UserRole.USER;
        emit AdminRemoved(_admin);
    }
    
    /**
     * @dev 创建新的足球赛事
     * @param _homeTeam 主队名称
     * @param _awayTeam 客队名称
     * @param _matchTime 比赛时间（时间戳）
     * @param _venue 比赛场地
     */
    function createMatch(
        string memory _homeTeam,
        string memory _awayTeam,
        uint256 _matchTime,
        string memory _venue
    ) external onlyAdmin {
        require(bytes(_homeTeam).length > 0, "Home team name cannot be empty");
        require(bytes(_awayTeam).length > 0, "Away team name cannot be empty");
        require(_matchTime > block.timestamp, "Match time must be in the future");
        require(bytes(_venue).length > 0, "Venue cannot be empty");
        
        uint256 matchId = nextMatchId++;
        
        matches[matchId] = Match({
            matchId: matchId,
            homeTeam: _homeTeam,
            awayTeam: _awayTeam,
            matchTime: _matchTime,
            venue: _venue,
            isActive: true,
            createdAt: block.timestamp
        });
        
        emit MatchCreated(matchId, _homeTeam, _awayTeam, _matchTime);
    }
    
    /**
     * @dev 为指定赛事创建门票类型
     * @param _matchId 赛事ID
     * @param _category 门票类别
     * @param _price 门票价格（原生MON代币，以wei为单位）
     * @param _totalSupply 总供应量
     */
    function createTicketType(
        uint256 _matchId,
        string memory _category,
        uint256 _price,
        uint256 _totalSupply
    ) external onlyAdmin validMatch(_matchId) {
        require(bytes(_category).length > 0, "Category cannot be empty");
        require(_price > 0, "Price must be greater than 0");
        require(_totalSupply > 0, "Total supply must be greater than 0");
        
        uint256 typeId = nextTypeId++;
        
        ticketTypes[typeId] = TicketType({
            typeId: typeId,
            matchId: _matchId,
            category: _category,
            price: _price,
            totalSupply: _totalSupply,
            soldCount: 0,
            isActive: true
        });
        
        emit TicketTypeCreated(typeId, _matchId, _category, _price, _totalSupply);
    }
    
    /**
     * @dev 用户购买门票（使用原生MON代币）
     * @param _typeId 门票类型ID
     */
    function purchaseTicket(uint256 _typeId) external payable nonReentrant validTicketType(_typeId) {
        TicketType storage ticketType = ticketTypes[_typeId];
        require(ticketType.soldCount < ticketType.totalSupply, "Tickets sold out");
        
        Match storage matchInfo = matches[ticketType.matchId];
        require(matchInfo.matchTime > block.timestamp, "Match has already started or ended");
        
        uint256 price = ticketType.price;
        require(msg.value >= price, "Insufficient MON sent");
        
        // 创建门票
        uint256 ticketId = nextTicketId++;
        tickets[ticketId] = Ticket({
            ticketId: ticketId,
            typeId: _typeId,
            matchId: ticketType.matchId,
            owner: msg.sender,
            status: TicketStatus.SOLD,
            purchaseTime: block.timestamp,
            price: price
        });
        
        // 更新门票类型销售数量
        ticketType.soldCount++;
        
        // 添加到用户门票列表
        userTickets[msg.sender].push(ticketId);
        
        // 退还多余的MON代币
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        emit TicketPurchased(ticketId, _typeId, msg.sender, price);
    }
    
    /**
     * @dev 用户退票
     * @param _ticketId 门票ID
     */
    function refundTicket(uint256 _ticketId) external nonReentrant {
        require(_ticketId > 0 && _ticketId < nextTicketId, "Invalid ticket ID");
        
        Ticket storage ticket = tickets[_ticketId];
        require(ticket.owner == msg.sender, "You don't own this ticket");
        require(ticket.status == TicketStatus.SOLD, "Ticket is not refundable");
        
        Match storage matchInfo = matches[ticket.matchId];
        require(matchInfo.matchTime > block.timestamp + 3600, "Cannot refund within 1 hour of match time");
        
        // 计算退款金额（可以设置手续费）
        uint256 refundAmount = ticket.price;
        
        // 检查合约余额
        require(address(this).balance >= refundAmount, "Insufficient contract balance for refund");
        
        // 更新门票状态
        ticket.status = TicketStatus.REFUNDED;
        
        // 更新门票类型销售数量
        ticketTypes[ticket.typeId].soldCount--;
        
        // 退款原生MON代币
        payable(msg.sender).transfer(refundAmount);
        
        emit TicketRefunded(_ticketId, msg.sender, refundAmount);
    }
    
    /**
     * @dev 获取所有活跃的赛事
     */
    function getActiveMatches() external view returns (Match[] memory) {
        uint256 activeCount = 0;
        
        // 首先计算活跃赛事数量
        for (uint256 i = 1; i < nextMatchId; i++) {
            if (matches[i].isActive) {
                activeCount++;
            }
        }
        
        // 创建结果数组
        Match[] memory activeMatches = new Match[](activeCount);
        uint256 index = 0;
        
        // 填充结果数组
        for (uint256 i = 1; i < nextMatchId; i++) {
            if (matches[i].isActive) {
                activeMatches[index] = matches[i];
                index++;
            }
        }
        
        return activeMatches;
    }
    
    /**
     * @dev 获取指定赛事的门票类型
     * @param _matchId 赛事ID
     */
    function getMatchTicketTypes(uint256 _matchId) external view returns (TicketType[] memory) {
        uint256 count = 0;
        
        // 计算该赛事的门票类型数量
        for (uint256 i = 1; i < nextTypeId; i++) {
            if (ticketTypes[i].matchId == _matchId && ticketTypes[i].isActive) {
                count++;
            }
        }
        
        // 创建结果数组
        TicketType[] memory matchTypes = new TicketType[](count);
        uint256 index = 0;
        
        // 填充结果数组
        for (uint256 i = 1; i < nextTypeId; i++) {
            if (ticketTypes[i].matchId == _matchId && ticketTypes[i].isActive) {
                matchTypes[index] = ticketTypes[i];
                index++;
            }
        }
        
        return matchTypes;
    }
    
    /**
     * @dev 获取用户拥有的门票
     * @param _user 用户地址
     */
    function getUserTickets(address _user) external view returns (Ticket[] memory) {
        uint256[] memory ticketIds = userTickets[_user];
        Ticket[] memory userTicketList = new Ticket[](ticketIds.length);
        
        for (uint256 i = 0; i < ticketIds.length; i++) {
            userTicketList[i] = tickets[ticketIds[i]];
        }
        
        return userTicketList;
    }
    
    /**
     * @dev 管理员设置赛事状态
     * @param _matchId 赛事ID
     * @param _isActive 是否激活
     */
    function setMatchStatus(uint256 _matchId, bool _isActive) external onlyAdmin {
        require(_matchId > 0 && _matchId < nextMatchId, "Invalid match ID");
        matches[_matchId].isActive = _isActive;
        emit MatchStatusChanged(_matchId, _isActive);
    }
    
    /**
     * @dev 管理员提取合约中的原生MON代币
     * @param _amount 提取数量
     */
    function withdrawMON(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient contract balance");
        payable(owner()).transfer(_amount);
    }
    
    /**
     * @dev 检查地址是否为管理员
     * @param _address 要检查的地址
     */
    function isAdmin(address _address) external view returns (bool) {
        return admins[_address] || _address == owner();
    }
    
    /**
     * @dev 获取合约原生MON代币余额
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev 紧急提取所有原生MON代币（仅合约拥有者）
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    /**
     * @dev 接收原生MON代币的fallback函数
     */
    receive() external payable {
        // 允许合约接收原生代币
    }
    
    /**
     * @dev fallback函数
     */
    fallback() external payable {
        // 允许合约接收原生代币
    }
}
