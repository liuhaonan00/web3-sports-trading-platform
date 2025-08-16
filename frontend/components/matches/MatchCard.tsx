import { useState } from 'react'
import { Calendar, MapPin, Users, Ticket } from 'lucide-react'
import Card, { CardHeader, CardTitle, CardContent, CardFooter } from '@/components/ui/Card'
import Button from '@/components/ui/Button'
import Badge from '@/components/ui/Badge'
import { Match, TicketType } from '@/config/abi'
import { formatDate, formatMON } from '@/config/constants'
import { useTicketing } from '@/hooks/useTicketing'
import TicketPurchaseModal from './TicketPurchaseModal'

interface MatchCardProps {
  match: Match
  showAdminActions?: boolean
}

export default function MatchCard({ match, showAdminActions = false }: MatchCardProps) {
  const { getMatchTicketTypes, setMatchStatus, loading } = useTicketing()
  const [ticketTypes, setTicketTypes] = useState<TicketType[]>([])
  const [showTickets, setShowTickets] = useState(false)
  const [showPurchaseModal, setShowPurchaseModal] = useState(false)
  const [loadingTickets, setLoadingTickets] = useState(false)

  const handleViewTickets = async () => {
    if (showTickets) {
      setShowTickets(false)
      return
    }

    setLoadingTickets(true)
    try {
      const types = await getMatchTicketTypes(match.matchId)
      setTicketTypes(types)
      setShowTickets(true)
    } catch (error) {
      console.error('Failed to load ticket types:', error)
    } finally {
      setLoadingTickets(false)
    }
  }

  const handleToggleMatchStatus = async () => {
    await setMatchStatus(match.matchId, !match.isActive)
  }

  const matchDate = new Date(Number(match.matchTime) * 1000)
  const isUpcoming = matchDate > new Date()

  return (
    <>
      <Card hover className="animate-fade-in">
        <CardHeader>
          <div className="flex justify-between items-start">
            <CardTitle className="text-xl">
              {match.homeTeam} vs {match.awayTeam}
            </CardTitle>
            <Badge variant={match.isActive ? 'success' : 'error'}>
              {match.isActive ? '进行中' : '已停用'}
            </Badge>
          </div>
        </CardHeader>

        <CardContent>
          <div className="space-y-3">
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

            {/* 显示门票类型 */}
            {showTickets && (
              <div className="mt-4 space-y-2">
                <h4 className="font-medium text-gray-900 flex items-center">
                  <Ticket className="h-4 w-4 mr-2" />
                  门票类型
                </h4>
                {ticketTypes.length > 0 ? (
                  <div className="space-y-2">
                    {ticketTypes.map((ticketType) => (
                      <div key={Number(ticketType.typeId)} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                        <div>
                          <span className="font-medium">{ticketType.category}</span>
                          <div className="text-sm text-gray-600">
                            {formatMON(ticketType.price)} MON
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="text-sm font-medium">
                            剩余: {Number(ticketType.totalSupply - ticketType.soldCount)}
                          </div>
                          <div className="text-xs text-gray-500">
                            总计: {Number(ticketType.totalSupply)}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-gray-500 text-sm">暂无门票类型</p>
                )}
              </div>
            )}
          </div>
        </CardContent>

        <CardFooter>
          <div className="flex gap-2 w-full">
            <Button
              variant="outline"
              onClick={handleViewTickets}
              loading={loadingTickets}
              className="flex-1"
            >
              <Users className="h-4 w-4 mr-2" />
              {showTickets ? '隐藏门票' : '查看门票'}
            </Button>
            
            {isUpcoming && showTickets && ticketTypes.length > 0 && (
              <Button
                onClick={() => setShowPurchaseModal(true)}
                className="flex-1"
              >
                <Ticket className="h-4 w-4 mr-2" />
                购买门票
              </Button>
            )}

            {showAdminActions && (
              <Button
                variant={match.isActive ? 'danger' : 'success'}
                onClick={handleToggleMatchStatus}
                loading={loading}
                size="sm"
              >
                {match.isActive ? '停用' : '激活'}
              </Button>
            )}
          </div>
        </CardFooter>
      </Card>

      {/* 购票模态框 */}
      <TicketPurchaseModal
        isOpen={showPurchaseModal}
        onClose={() => setShowPurchaseModal(false)}
        match={match}
        ticketTypes={ticketTypes}
      />
    </>
  )
}
