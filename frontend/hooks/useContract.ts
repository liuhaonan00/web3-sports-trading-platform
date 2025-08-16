import { usePrivy } from '@privy-io/react-auth'
import { Contract, JsonRpcProvider, BrowserProvider } from 'ethers'
import { useMemo } from 'react'
import { TICKETING_SYSTEM_ABI } from '@/config/abi'
import { TICKETING_CONTRACT_ADDRESS, MONAD_TESTNET } from '@/config/constants'

export function useContract() {
  const { user } = usePrivy()

  const { readContract, writeContract, provider } = useMemo(() => {
    // 创建只读provider
    const readProvider = new JsonRpcProvider(MONAD_TESTNET.rpcUrls.default.http[0])
    const readContract = new Contract(TICKETING_CONTRACT_ADDRESS, TICKETING_SYSTEM_ABI, readProvider)

    // 如果有连接的钱包，创建可写合约
    let writeContract = null
    let provider = null

    if (user?.wallet?.address && window.ethereum) {
      try {
        // 使用浏览器钱包
        provider = new BrowserProvider(window.ethereum)
        writeContract = new Contract(TICKETING_CONTRACT_ADDRESS, TICKETING_SYSTEM_ABI, provider)
      } catch (error) {
        console.error('Failed to create write contract:', error)
      }
    }

    return { readContract, writeContract, provider }
  }, [user?.wallet?.address])

  return { readContract, writeContract, provider }
}

// 获取signer的hook
export function useSigner() {
  const { provider } = useContract()
  
  const getSigner = async () => {
    if (!provider) throw new Error('No provider available')
    return await provider.getSigner()
  }

  return { getSigner }
}
