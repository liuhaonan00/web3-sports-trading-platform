// TicketingSystemNative合约ABI
export const TICKETING_SYSTEM_ABI = [
  // 读取函数
  "function matches(uint256) view returns (uint256 matchId, string homeTeam, string awayTeam, uint256 matchTime, string venue, bool isActive, uint256 createdAt)",
  "function ticketTypes(uint256) view returns (uint256 typeId, uint256 matchId, string category, uint256 price, uint256 totalSupply, uint256 soldCount, bool isActive)",
  "function tickets(uint256) view returns (uint256 ticketId, uint256 typeId, uint256 matchId, address owner, uint8 status, uint256 purchaseTime, uint256 price)",
  "function userRoles(address) view returns (uint8)",
  "function admins(address) view returns (bool)",
  "function isAdmin(address) view returns (bool)",
  "function getActiveMatches() view returns (tuple(uint256 matchId, string homeTeam, string awayTeam, uint256 matchTime, string venue, bool isActive, uint256 createdAt)[])",
  "function getMatchTicketTypes(uint256 matchId) view returns (tuple(uint256 typeId, uint256 matchId, string category, uint256 price, uint256 totalSupply, uint256 soldCount, bool isActive)[])",
  "function getUserTickets(address user) view returns (tuple(uint256 ticketId, uint256 typeId, uint256 matchId, address owner, uint8 status, uint256 purchaseTime, uint256 price)[])",
  "function getContractBalance() view returns (uint256)",
  "function nextMatchId() view returns (uint256)",
  "function nextTypeId() view returns (uint256)",
  "function nextTicketId() view returns (uint256)",
  "function owner() view returns (address)",
  
  // 写入函数
  "function addAdmin(address admin)",
  "function removeAdmin(address admin)",
  "function createMatch(string homeTeam, string awayTeam, uint256 matchTime, string venue)",
  "function createTicketType(uint256 matchId, string category, uint256 price, uint256 totalSupply)",
  "function purchaseTicket(uint256 typeId) payable",
  "function refundTicket(uint256 ticketId)",
  "function setMatchStatus(uint256 matchId, bool isActive)",
  "function withdrawMON(uint256 amount)",
  "function emergencyWithdraw()",
  
  // 事件
  "event AdminAdded(address indexed admin)",
  "event AdminRemoved(address indexed admin)",
  "event MatchCreated(uint256 indexed matchId, string homeTeam, string awayTeam, uint256 matchTime)",
  "event TicketTypeCreated(uint256 indexed typeId, uint256 indexed matchId, string category, uint256 price, uint256 totalSupply)",
  "event TicketPurchased(uint256 indexed ticketId, uint256 indexed typeId, address indexed buyer, uint256 price)",
  "event TicketRefunded(uint256 indexed ticketId, address indexed owner, uint256 refundAmount)",
  "event MatchStatusChanged(uint256 indexed matchId, bool isActive)"
] as const

// 类型定义
export interface Match {
  matchId: bigint
  homeTeam: string
  awayTeam: string
  matchTime: bigint
  venue: string
  isActive: boolean
  createdAt: bigint
}

export interface TicketType {
  typeId: bigint
  matchId: bigint
  category: string
  price: bigint
  totalSupply: bigint
  soldCount: bigint
  isActive: boolean
}

export interface Ticket {
  ticketId: bigint
  typeId: bigint
  matchId: bigint
  owner: string
  status: number
  purchaseTime: bigint
  price: bigint
}
