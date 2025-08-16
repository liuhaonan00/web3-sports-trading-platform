// 网络配置
export const MONAD_TESTNET = {
  id: parseInt(process.env.NEXT_PUBLIC_CHAIN_ID || '10143'),
  name: process.env.NEXT_PUBLIC_CHAIN_NAME || 'Monad Testnet',
  network: 'monad-testnet',
  nativeCurrency: {
    decimals: parseInt(process.env.NEXT_PUBLIC_NATIVE_CURRENCY_DECIMALS || '18'),
    name: process.env.NEXT_PUBLIC_NATIVE_CURRENCY_NAME || 'MON',
    symbol: process.env.NEXT_PUBLIC_NATIVE_CURRENCY_SYMBOL || 'MON',
  },
  rpcUrls: {
    default: {
      http: [process.env.NEXT_PUBLIC_RPC_URL || 'https://testnet-rpc.monad.xyz'],
    },
    public: {
      http: [process.env.NEXT_PUBLIC_RPC_URL || 'https://testnet-rpc.monad.xyz'],
    },
  },
  blockExplorers: {
    default: { 
      name: 'Monad Explorer', 
      url: process.env.NEXT_PUBLIC_BLOCK_EXPLORER_URL || 'https://testnet.monadexplorer.com' 
    },
  },
}

// 合约地址
export const TICKETING_CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_TICKETING_CONTRACT_ADDRESS || '0x8587382627bDee45B42967b920f734b0ddA931C3'

// Privy配置
export const PRIVY_APP_ID = process.env.NEXT_PUBLIC_PRIVY_APP_ID || ''

// 用户角色
export enum UserRole {
  USER = 0,
  ADMIN = 1
}

// 门票状态
export enum TicketStatus {
  AVAILABLE = 0,
  SOLD = 1,
  REFUNDED = 2
}

// 格式化工具
export const formatMON = (wei: bigint): string => {
  return (Number(wei) / 1e18).toFixed(4)
}

export const parseMON = (mon: string): bigint => {
  return BigInt(Math.floor(parseFloat(mon) * 1e18))
}

export const formatDate = (timestamp: number): string => {
  return new Date(timestamp * 1000).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

export const getTicketStatusText = (status: TicketStatus): string => {
  switch (status) {
    case TicketStatus.AVAILABLE:
      return '可购买'
    case TicketStatus.SOLD:
      return '已售出'
    case TicketStatus.REFUNDED:
      return '已退票'
    default:
      return '未知'
  }
}

export const getTicketStatusClass = (status: TicketStatus): string => {
  switch (status) {
    case TicketStatus.AVAILABLE:
      return 'badge-success'
    case TicketStatus.SOLD:
      return 'badge-warning'
    case TicketStatus.REFUNDED:
      return 'badge-error'
    default:
      return 'badge-error'
  }
}
