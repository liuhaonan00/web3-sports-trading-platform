// 调试脚本，用于测试合约调用
const { ethers } = require('ethers');

const TICKETING_CONTRACT_ADDRESS = '0x8587382627bDee45B42967b920f734b0ddA931C3';
const USER_ADDRESS = '0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a';
const RPC_URL = 'https://testnet-rpc.monad.xyz';

const ABI = [
  "function getUserTickets(address user) view returns (tuple(uint256 ticketId, uint256 typeId, uint256 matchId, address owner, uint8 status, uint256 purchaseTime, uint256 price)[])",
  "function tickets(uint256) view returns (uint256 ticketId, uint256 typeId, uint256 matchId, address owner, uint8 status, uint256 purchaseTime, uint256 price)",
  "function nextTicketId() view returns (uint256)"
];

async function debug() {
  console.log('🔍 开始调试合约调用...');
  
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const contract = new ethers.Contract(TICKETING_CONTRACT_ADDRESS, ABI, provider);
  
  try {
    // 检查合约连接
    console.log('📡 检查合约连接...');
    const nextTicketId = await contract.nextTicketId();
    console.log('✅ 下个门票ID:', nextTicketId.toString());
    
    // 检查用户门票
    console.log('🎫 获取用户门票...');
    const userTickets = await contract.getUserTickets(USER_ADDRESS);
    console.log('✅ 用户门票数量:', userTickets.length);
    
    if (userTickets.length > 0) {
      console.log('📋 门票详情:');
      userTickets.forEach((ticket, index) => {
        console.log(`门票 ${index + 1}:`);
        console.log(`  - ID: ${ticket.ticketId.toString()}`);
        console.log(`  - 类型ID: ${ticket.typeId.toString()}`);
        console.log(`  - 赛事ID: ${ticket.matchId.toString()}`);
        console.log(`  - 拥有者: ${ticket.owner}`);
        console.log(`  - 状态: ${ticket.status}`);
        console.log(`  - 价格: ${ethers.formatEther(ticket.price)} MON`);
        console.log(`  - 购买时间: ${new Date(Number(ticket.purchaseTime) * 1000).toLocaleString()}`);
        console.log('---');
      });
    } else {
      console.log('❌ 没有找到门票');
    }
    
  } catch (error) {
    console.error('❌ 调试过程中出错:', error);
  }
}

debug();
