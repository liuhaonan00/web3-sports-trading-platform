'use client'

import { PrivyProvider, PrivyClientConfig } from '@privy-io/react-auth'
import { WagmiProvider } from '@privy-io/wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { createConfig, http } from 'wagmi'
import { MONAD_TESTNET, PRIVY_APP_ID } from '@/config/constants'

// 创建Wagmi配置
const wagmiConfig = createConfig({
  chains: [MONAD_TESTNET],
  transports: {
    [MONAD_TESTNET.id]: http(),
  },
})

// 创建QueryClient
const queryClient = new QueryClient()

// Privy配置
const privyConfig: PrivyClientConfig = {
  appearance: {
    theme: 'light',
    accentColor: '#3b82f6',
    logo: '/logo.png',
    showWalletLoginFirst: true,
  },
  embeddedWallets: {
    createOnLogin: 'users-without-wallets',
    requireUserPasswordOnCreate: false,
  },
  loginMethods: ['wallet', 'email', 'sms'],
  defaultChain: MONAD_TESTNET,
  supportedChains: [MONAD_TESTNET],
}

interface ProvidersProps {
  children: React.ReactNode
}

export default function Providers({ children }: ProvidersProps) {
  if (!PRIVY_APP_ID) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-red-600 mb-2">配置错误</h2>
          <p className="text-gray-600">
            请在环境变量中设置 NEXT_PUBLIC_PRIVY_APP_ID
          </p>
        </div>
      </div>
    )
  }

  return (
    <PrivyProvider
      appId={PRIVY_APP_ID}
      config={privyConfig}
    >
      <QueryClientProvider client={queryClient}>
        <WagmiProvider config={wagmiConfig}>
          {children}
        </WagmiProvider>
      </QueryClientProvider>
    </PrivyProvider>
  )
}
