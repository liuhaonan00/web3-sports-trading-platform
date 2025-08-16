import { useState, useEffect } from 'react'
import { Ticket as TicketIcon, Calendar, MapPin, RefreshCw } from 'lucide-react'
import Card, { CardHeader, CardTitle, CardContent, CardFooter } from '@/components/ui/Card'
import Button from '@/components/ui/Button'
import Badge from '@/components/ui/Badge'
import { Ticket, Match, TicketType } from '@/config/abi'
import { formatDate, formatMON, TicketStatus, getTicketStatusText, getTicketStatusClass } from '@/config/constants'
import { useTicketing } from '@/hooks/useTicketing'
import { useContract } from '@/hooks/useContract'
import toast from 'react-hot-toast'

interface UserTicketCardProps {
  ticket: Ticket
}

export default function UserTicketCard({ ticket }: UserTicketCardProps) {
  const { refundTicket, loading } = useTicketing()
  const { readContract } = useContract()
  const [match, setMatch] = useState<Match | null>(null)
  const [ticketType, setTicketType] = useState<TicketType | null>(null)
  const [loadingDetails, setLoadingDetails] = useState(true)

  // 获取赛事和门票类型详情
  useEffect(() => {
    async function fetchDetails() {
      if (!readContract) return

      try {
        setLoadingDetails(true)
        
        // 获取赛事信息
        const matchData = await readContract.matches(ticket.matchId)
        setMatch(matchData)
        
        // 获取门票类型信息
        const ticketTypeData = await readContract.ticketTypes(ticket.typeId)
        setTicketType(ticketTypeData)
      } catch (error) {
        console.error('Error fetching ticket details:', error)
        toast.error('获取门票详情失败')
      } finally {
        setLoadingDetails(false)
      }
    }

    fetchDetails()
  }, [ticket.matchId, ticket.typeId, readContract])

  const handleRefund = async () => {
    const success = await refundTicket(ticket.ticketId)
    if (success) {
      // 刷新页面或更新状态
      window.location.reload()
    }
  }

  if (loadingDetails || !match || !ticketType) {
    return (
      <Card>
        <CardContent>
          <div className="animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
            <div className="h-4 bg-gray-200 rounded w-2/3"></div>
          </div>
        </CardContent>
      </Card>
    )
  }

  const matchDate = new Date(Number(match.matchTime) * 1000)
  const purchaseDate = new Date(Number(ticket.purchaseTime) * 1000)
  const canRefund = ticket.status === TicketStatus.SOLD && 
                   matchDate > new Date(Date.now() + 3600000) // 比赛开始前1小时
  const isUpcoming = matchDate > new Date()

  return (
    <Card className="animate-slide-up">
      <CardHeader>
        <div className="flex justify-between items-start">
          <CardTitle className="text-lg flex items-center">
            <TicketIcon className="h-5 w-5 mr-2" />
            {match.homeTeam} vs {match.awayTeam}
          </CardTitle>
          <Badge variant={getTicketStatusClass(ticket.status) as any}>
            {getTicketStatusText(ticket.status)}
          </Badge>
        </div>
      </CardHeader>

      <CardContent>
        <div className="space-y-3">
          {/* 门票信息 */}
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-gray-500">门票类型:</span>
              <p className="font-medium">{ticketType.category}</p>
            </div>
            <div>
              <span className="text-gray-500">门票ID:</span>
              <p className="font-medium">#{Number(ticket.ticketId)}</p>
            </div>
          </div>

          {/* 赛事信息 */}
          <div className="space-y-2">
            <div className="flex items-center text-gray-600">
              <Calendar className="h-4 w-4 mr-2" />
              <span>{formatDate(Number(match.matchTime))}</span>
              {!isUpcoming && (
                <Badge variant="warning" className="ml-2">已结束</Badge>
              )}
            </div>
            
            <div className="flex items-center text-gray-600">
              <MapPin className="h-4 w-4 mr-2" />
              <span>{match.venue}</span>
            </div>
          </div>

          {/* 价格信息 */}
          <div className="bg-gray-50 p-3 rounded-lg">
            <div className="flex justify-between items-center">
              <span className="text-gray-600">支付金额:</span>
              <span className="font-semibold text-lg text-primary-600">
                {formatMON(ticket.price)} MON
              </span>
            </div>
            <div className="flex justify-between items-center text-sm text-gray-500 mt-1">
              <span>购买时间:</span>
              <span>{purchaseDate.toLocaleDateString('zh-CN')}</span>
            </div>
          </div>

          {/* 退票说明 */}
          {ticket.status === TicketStatus.SOLD && (
            <div className="text-xs text-gray-500">
              {canRefund ? (
                <p className="text-success-600">
                  ✓ 可以退票 (比赛开始前1小时截止)
                </p>
              ) : (
                <p className="text-error-600">
                  ✗ 无法退票 (距离比赛开始不足1小时)
                </p>
              )}
            </div>
          )}
        </div>
      </CardContent>

      {canRefund && (
        <CardFooter>
          <Button
            variant="danger"
            onClick={handleRefund}
            loading={loading}
            className="w-full flex items-center justify-center gap-2"
          >
            <RefreshCw className="h-4 w-4" />
            申请退票
          </Button>
        </CardFooter>
      )}
    </Card>
  )
}
