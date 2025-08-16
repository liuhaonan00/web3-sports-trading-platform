import { useState } from 'react'
import { Ticket, CreditCard } from 'lucide-react'
import Modal, { ModalFooter } from '@/components/ui/Modal'
import Button from '@/components/ui/Button'
import Badge from '@/components/ui/Badge'
import { Match, TicketType } from '@/config/abi'
import { formatMON } from '@/config/constants'
import { useTicketing } from '@/hooks/useTicketing'
import toast from 'react-hot-toast'

interface TicketPurchaseModalProps {
  isOpen: boolean
  onClose: () => void
  match: Match
  ticketTypes: TicketType[]
}

export default function TicketPurchaseModal({ 
  isOpen, 
  onClose, 
  match, 
  ticketTypes 
}: TicketPurchaseModalProps) {
  const { purchaseTicket, loading } = useTicketing()
  const [selectedTypeId, setSelectedTypeId] = useState<bigint | null>(null)

  const selectedTicketType = ticketTypes.find(t => t.typeId === selectedTypeId)
  const availableTicketTypes = ticketTypes.filter(t => t.isActive && t.soldCount < t.totalSupply)

  const handlePurchase = async () => {
    if (!selectedTicketType) {
      toast.error('请选择门票类型')
      return
    }

    const success = await purchaseTicket(selectedTicketType.typeId, selectedTicketType.price)
    if (success) {
      onClose()
      setSelectedTypeId(null)
    }
  }

  const handleClose = () => {
    onClose()
    setSelectedTypeId(null)
  }

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="购买门票"
      size="md"
    >
      <div className="space-y-6">
        {/* 赛事信息 */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold text-lg text-gray-900">
            {match.homeTeam} vs {match.awayTeam}
          </h3>
          <p className="text-gray-600 mt-1">
            {new Date(Number(match.matchTime) * 1000).toLocaleDateString('zh-CN', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
              hour: '2-digit',
              minute: '2-digit'
            })}
          </p>
          <p className="text-gray-600">{match.venue}</p>
        </div>

        {/* 门票类型选择 */}
        <div>
          <h4 className="font-medium text-gray-900 mb-3 flex items-center">
            <Ticket className="h-4 w-4 mr-2" />
            选择门票类型
          </h4>

          {availableTicketTypes.length > 0 ? (
            <div className="space-y-3">
              {availableTicketTypes.map((ticketType) => {
                const isSelected = selectedTypeId === ticketType.typeId
                const remaining = Number(ticketType.totalSupply - ticketType.soldCount)
                
                return (
                  <div
                    key={Number(ticketType.typeId)}
                    className={`border-2 rounded-lg p-4 cursor-pointer transition-colors ${
                      isSelected 
                        ? 'border-primary-500 bg-primary-50' 
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                    onClick={() => setSelectedTypeId(ticketType.typeId)}
                  >
                    <div className="flex justify-between items-center">
                      <div>
                        <h5 className="font-medium text-gray-900">
                          {ticketType.category}
                        </h5>
                        <p className="text-lg font-semibold text-primary-600">
                          {formatMON(ticketType.price)} MON
                        </p>
                      </div>
                      <div className="text-right">
                        <Badge variant={remaining > 10 ? 'success' : 'warning'}>
                          剩余 {remaining} 张
                        </Badge>
                        <p className="text-sm text-gray-500 mt-1">
                          总计 {Number(ticketType.totalSupply)} 张
                        </p>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          ) : (
            <div className="text-center py-8">
              <Ticket className="h-12 w-12 mx-auto text-gray-400 mb-4" />
              <p className="text-gray-500">暂无可购买的门票</p>
            </div>
          )}
        </div>

        {/* 购买信息 */}
        {selectedTicketType && (
          <div className="bg-blue-50 p-4 rounded-lg">
            <h5 className="font-medium text-gray-900 mb-2">购买详情</h5>
            <div className="space-y-1 text-sm">
              <div className="flex justify-between">
                <span>门票类型:</span>
                <span className="font-medium">{selectedTicketType.category}</span>
              </div>
              <div className="flex justify-between">
                <span>单价:</span>
                <span className="font-medium">{formatMON(selectedTicketType.price)} MON</span>
              </div>
              <div className="flex justify-between">
                <span>数量:</span>
                <span className="font-medium">1 张</span>
              </div>
              <div className="border-t pt-2 mt-2 flex justify-between font-semibold">
                <span>总计:</span>
                <span className="text-primary-600">{formatMON(selectedTicketType.price)} MON</span>
              </div>
            </div>
          </div>
        )}
      </div>

      <ModalFooter>
        <Button
          variant="secondary"
          onClick={handleClose}
        >
          取消
        </Button>
        <Button
          onClick={handlePurchase}
          loading={loading}
          disabled={!selectedTicketType}
          className="flex items-center gap-2"
        >
          <CreditCard className="h-4 w-4" />
          确认购买
        </Button>
      </ModalFooter>
    </Modal>
  )
}
