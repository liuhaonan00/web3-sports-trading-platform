'use client'

import { useEffect, useState } from 'react'
import { usePrivy } from '@privy-io/react-auth'
import { useContract } from '@/hooks/useContract'
import { useTicketing } from '@/hooks/useTicketing'
import Card from '@/components/ui/Card'
import Button from '@/components/ui/Button'

export default function DebugInfo() {
  const { user, ready } = usePrivy()
  const { readContract } = useContract()
  const { userTickets, fetchUserTickets } = useTicketing()
  const [debugInfo, setDebugInfo] = useState<any>(null)
  const [loading, setLoading] = useState(false)

  const runDebug = async () => {
    if (!user?.wallet?.address || !readContract) {
      setDebugInfo({ error: 'User not connected or contract not available' })
      return
    }

    setLoading(true)
    try {
      // 直接调用合约获取门票
      const directTickets = await readContract.getUserTickets(user.wallet.address)
      
      // 获取下一个门票ID
      const nextTicketId = await readContract.nextTicketId()
      
      setDebugInfo({
        userAddress: user.wallet.address,
        nextTicketId: nextTicketId.toString(),
        directTicketsCount: directTickets.length,
        directTickets: directTickets.map((ticket: any) => ({
          ticketId: ticket.ticketId.toString(),
          typeId: ticket.typeId.toString(),
          matchId: ticket.matchId.toString(),
          owner: ticket.owner,
          status: ticket.status.toString(),
          price: ticket.price.toString(),
          purchaseTime: ticket.purchaseTime.toString()
        })),
        hookTicketsCount: userTickets.length,
        hookTickets: userTickets.map(ticket => ({
          ticketId: ticket.ticketId.toString(),
          typeId: ticket.typeId.toString(),
          matchId: ticket.matchId.toString(),
          owner: ticket.owner,
          status: ticket.status.toString(),
          price: ticket.price.toString(),
          purchaseTime: ticket.purchaseTime.toString()
        }))
      })
    } catch (error: any) {
      setDebugInfo({ error: error.message })
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="mb-6 bg-yellow-50 border-yellow-200">
      <div className="space-y-4">
        <h3 className="text-lg font-semibold text-yellow-800">🐛 调试信息</h3>
        
        <div className="text-sm">
          <p><strong>用户准备状态:</strong> {ready ? '✅' : '❌'}</p>
          <p><strong>用户钱包:</strong> {user?.wallet?.address || '未连接'}</p>
          <p><strong>合约可用:</strong> {readContract ? '✅' : '❌'}</p>
          <p><strong>Hook门票数量:</strong> {userTickets.length}</p>
        </div>

        <div className="flex gap-2">
          <Button onClick={runDebug} loading={loading} size="sm">
            运行调试
          </Button>
          <Button onClick={fetchUserTickets} size="sm" variant="secondary">
            刷新门票
          </Button>
        </div>

        {debugInfo && (
          <div className="bg-white p-4 rounded-lg border">
            <h4 className="font-medium mb-2">调试结果:</h4>
            <pre className="text-xs overflow-auto bg-gray-100 p-2 rounded">
              {JSON.stringify(debugInfo, null, 2)}
            </pre>
          </div>
        )}
      </div>
    </Card>
  )
}
