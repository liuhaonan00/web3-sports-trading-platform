import { useState, useEffect, useCallback } from 'react'
import { usePrivy } from '@privy-io/react-auth'
import { useContract, useSigner } from './useContract'
import { Match, TicketType, Ticket } from '@/config/abi'
import { UserRole, parseMON } from '@/config/constants'
import toast from 'react-hot-toast'

export function useTicketing() {
  const { user } = usePrivy()
  const { readContract, writeContract } = useContract()
  const { getSigner } = useSigner()
  
  const [loading, setLoading] = useState(false)
  const [isAdmin, setIsAdmin] = useState(false)
  const [matches, setMatches] = useState<Match[]>([])
  const [userTickets, setUserTickets] = useState<Ticket[]>([])

  // 检查用户是否是管理员
  const checkAdminStatus = useCallback(async () => {
    if (!user?.wallet?.address || !readContract) return

    try {
      const adminStatus = await (readContract as any).isAdmin(user.wallet.address)
      setIsAdmin(adminStatus)
    } catch (error) {
      console.error('Error checking admin status:', error)
    }
  }, [user?.wallet?.address, readContract])

  // 获取所有活跃赛事
  const fetchMatches = useCallback(async () => {
    if (!readContract) return

    try {
      setLoading(true)
      const activeMatches = await (readContract as any).getActiveMatches()
      setMatches(activeMatches)
    } catch (error) {
      console.error('Error fetching matches:', error)
      toast.error('获取赛事列表失败')
    } finally {
      setLoading(false)
    }
  }, [readContract])

  // 获取用户门票
  const fetchUserTickets = useCallback(async () => {
    if (!user?.wallet?.address || !readContract) return

    try {
      const tickets = await (readContract as any).getUserTickets(user.wallet.address)
      setUserTickets(tickets)
    } catch (error) {
      console.error('Error fetching user tickets:', error)
      toast.error('获取用户门票失败')
    }
  }, [user?.wallet?.address, readContract])

  // 获取指定赛事的门票类型
  const getMatchTicketTypes = useCallback(async (matchId: bigint): Promise<TicketType[]> => {
    if (!readContract) return []

    try {
      const ticketTypes = await (readContract as any).getMatchTicketTypes(matchId)
      return ticketTypes
    } catch (error) {
      console.error('Error fetching ticket types:', error)
      toast.error('获取门票类型失败')
      return []
    }
  }, [readContract])

  // 创建赛事（管理员）
  const createMatch = useCallback(async (
    homeTeam: string,
    awayTeam: string,
    matchTime: Date,
    venue: string
  ) => {
    if (!writeContract || !isAdmin) return false

    try {
      setLoading(true)
      const signer = await getSigner()
      const contractWithSigner = writeContract.connect(signer)
      
      const tx = await (contractWithSigner as any).createMatch(
        homeTeam,
        awayTeam,
        Math.floor(matchTime.getTime() / 1000),
        venue
      )
      
      await tx.wait()
      toast.success('赛事创建成功！')
      await fetchMatches()
      return true
    } catch (error: any) {
      console.error('Error creating match:', error)
      toast.error(error.message || '创建赛事失败')
      return false
    } finally {
      setLoading(false)
    }
  }, [writeContract, isAdmin, getSigner, fetchMatches])

  // 创建门票类型（管理员）
  const createTicketType = useCallback(async (
    matchId: bigint,
    category: string,
    price: string,
    totalSupply: number
  ) => {
    if (!writeContract || !isAdmin) return false

    try {
      setLoading(true)
      const signer = await getSigner()
      const contractWithSigner = writeContract.connect(signer)
      
      const tx = await (contractWithSigner as any).createTicketType(
        matchId,
        category,
        parseMON(price),
        BigInt(totalSupply)
      )
      
      await tx.wait()
      toast.success('门票类型创建成功！')
      return true
    } catch (error: any) {
      console.error('Error creating ticket type:', error)
      toast.error(error.message || '创建门票类型失败')
      return false
    } finally {
      setLoading(false)
    }
  }, [writeContract, isAdmin, getSigner])

  // 购买门票
  const purchaseTicket = useCallback(async (typeId: bigint, price: bigint) => {
    if (!writeContract || !user?.wallet?.address) return false

    try {
      setLoading(true)
      const signer = await getSigner()
      const contractWithSigner = writeContract.connect(signer)
      
      const tx = await (contractWithSigner as any).purchaseTicket(typeId, {
        value: price
      })
      
      await tx.wait()
      toast.success('购票成功！')
      await fetchUserTickets()
      await fetchMatches() // 刷新赛事列表以更新剩余票数
      return true
    } catch (error: any) {
      console.error('Error purchasing ticket:', error)
      toast.error(error.message || '购票失败')
      return false
    } finally {
      setLoading(false)
    }
  }, [writeContract, user?.wallet?.address, getSigner, fetchUserTickets, fetchMatches])

  // 退票
  const refundTicket = useCallback(async (ticketId: bigint) => {
    if (!writeContract || !user?.wallet?.address) return false

    try {
      setLoading(true)
      const signer = await getSigner()
      const contractWithSigner = writeContract.connect(signer)
      
      const tx = await (contractWithSigner as any).refundTicket(ticketId)
      
      await tx.wait()
      toast.success('退票成功！')
      await fetchUserTickets()
      await fetchMatches() // 刷新赛事列表以更新剩余票数
      return true
    } catch (error: any) {
      console.error('Error refunding ticket:', error)
      toast.error(error.message || '退票失败')
      return false
    } finally {
      setLoading(false)
    }
  }, [writeContract, user?.wallet?.address, getSigner, fetchUserTickets, fetchMatches])

  // 设置赛事状态（管理员）
  const setMatchStatus = useCallback(async (matchId: bigint, isActive: boolean) => {
    if (!writeContract || !isAdmin) return false

    try {
      setLoading(true)
      const signer = await getSigner()
      const contractWithSigner = writeContract.connect(signer)
      
      const tx = await (contractWithSigner as any).setMatchStatus(matchId, isActive)
      
      await tx.wait()
      toast.success(`赛事${isActive ? '激活' : '停用'}成功！`)
      await fetchMatches()
      return true
    } catch (error: any) {
      console.error('Error setting match status:', error)
      toast.error(error.message || '设置赛事状态失败')
      return false
    } finally {
      setLoading(false)
    }
  }, [writeContract, isAdmin, getSigner, fetchMatches])

  // 获取合约余额（管理员）
  const getContractBalance = useCallback(async (): Promise<bigint> => {
    if (!readContract) return BigInt(0)

    try {
      const balance = await (readContract as any).getContractBalance()
      return balance
    } catch (error) {
      console.error('Error getting contract balance:', error)
      return BigInt(0)
    }
  }, [readContract])

  // 提取合约收入（管理员）
  const withdrawMON = useCallback(async (amount: bigint) => {
    if (!writeContract || !isAdmin) return false

    try {
      setLoading(true)
      const signer = await getSigner()
      const contractWithSigner = writeContract.connect(signer)
      
      const tx = await (contractWithSigner as any).withdrawMON(amount)
      
      await tx.wait()
      toast.success('提取成功！')
      return true
    } catch (error: any) {
      console.error('Error withdrawing MON:', error)
      toast.error(error.message || '提取失败')
      return false
    } finally {
      setLoading(false)
    }
  }, [writeContract, isAdmin, getSigner])

  // 初始化数据
  useEffect(() => {
    checkAdminStatus()
    fetchMatches()
    fetchUserTickets()
  }, [checkAdminStatus, fetchMatches, fetchUserTickets])

  return {
    loading,
    isAdmin,
    matches,
    userTickets,
    fetchMatches,
    fetchUserTickets,
    getMatchTicketTypes,
    createMatch,
    createTicketType,
    purchaseTicket,
    refundTicket,
    setMatchStatus,
    getContractBalance,
    withdrawMON,
  }
}
