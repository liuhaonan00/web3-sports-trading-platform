// 全局类型声明

interface Window {
  ethereum?: {
    request: (args: { method: string; params?: any[] }) => Promise<any>
    on: (event: string, callback: (...args: any[]) => void) => void
    removeListener: (event: string, callback: (...args: any[]) => void) => void
    isMetaMask?: boolean
  }
}

// 扩展 Node.js 环境变量类型
declare namespace NodeJS {
  interface ProcessEnv {
    NEXT_PUBLIC_PRIVY_APP_ID: string
    NEXT_PUBLIC_TICKETING_CONTRACT_ADDRESS: string
    NEXT_PUBLIC_CHAIN_ID: string
    NEXT_PUBLIC_RPC_URL: string
    NEXT_PUBLIC_CHAIN_NAME: string
    NEXT_PUBLIC_NATIVE_CURRENCY_NAME: string
    NEXT_PUBLIC_NATIVE_CURRENCY_SYMBOL: string
    NEXT_PUBLIC_NATIVE_CURRENCY_DECIMALS: string
    NEXT_PUBLIC_BLOCK_EXPLORER_URL: string
  }
}

// 模块声明可以在这里添加其他需要的声明
