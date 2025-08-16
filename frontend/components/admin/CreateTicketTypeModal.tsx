import { useState } from 'react'
import { Ticket, DollarSign, Hash } from 'lucide-react'
import Modal, { ModalFooter } from '@/components/ui/Modal'
import Button from '@/components/ui/Button'
import Input from '@/components/ui/Input'
import { Match } from '@/config/abi'
import { useTicketing } from '@/hooks/useTicketing'

interface CreateTicketTypeModalProps {
  isOpen: boolean
  onClose: () => void
  matches: Match[]
}

interface FormData {
  matchId: string
  category: string
  price: string
  totalSupply: string
}

export default function CreateTicketTypeModal({ 
  isOpen, 
  onClose, 
  matches 
}: CreateTicketTypeModalProps) {
  const { createTicketType, loading } = useTicketing()
  const [formData, setFormData] = useState<FormData>({
    matchId: '',
    category: '',
    price: '',
    totalSupply: ''
  })
  const [errors, setErrors] = useState<Partial<FormData>>({})

  const handleInputChange = (field: keyof FormData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }))
    }
  }

  const validateForm = (): boolean => {
    const newErrors: Partial<FormData> = {}

    if (!formData.matchId) {
      newErrors.matchId = '请选择赛事'
    }
    if (!formData.category.trim()) {
      newErrors.category = '请输入门票类别'
    }
    if (!formData.price) {
      newErrors.price = '请输入门票价格'
    } else {
      const price = parseFloat(formData.price)
      if (isNaN(price) || price <= 0) {
        newErrors.price = '价格必须是大于0的数字'
      }
    }
    if (!formData.totalSupply) {
      newErrors.totalSupply = '请输入门票数量'
    } else {
      const supply = parseInt(formData.totalSupply)
      if (isNaN(supply) || supply <= 0) {
        newErrors.totalSupply = '数量必须是大于0的整数'
      }
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return

    const success = await createTicketType(
      BigInt(formData.matchId),
      formData.category.trim(),
      formData.price,
      parseInt(formData.totalSupply)
    )

    if (success) {
      handleClose()
    }
  }

  const handleClose = () => {
    setFormData({
      matchId: '',
      category: '',
      price: '',
      totalSupply: ''
    })
    setErrors({})
    onClose()
  }

  const selectedMatch = matches.find(m => m.matchId.toString() === formData.matchId)

  // 常用门票类别
  const commonCategories = ['VIP', 'Premium', 'Regular', 'Stand', 'Student']

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="创建门票类型"
      size="md"
    >
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* 选择赛事 */}
        <div>
          <label className="label">选择赛事</label>
          <select
            value={formData.matchId}
            onChange={(e) => handleInputChange('matchId', e.target.value)}
            className="input-field"
          >
            <option value="">请选择赛事</option>
            {matches.filter(m => m.isActive).map((match) => (
              <option key={match.matchId.toString()} value={match.matchId.toString()}>
                {match.homeTeam} vs {match.awayTeam} - {new Date(Number(match.matchTime) * 1000).toLocaleDateString()}
              </option>
            ))}
          </select>
          {errors.matchId && (
            <p className="text-sm text-error-600 mt-1">{errors.matchId}</p>
          )}
        </div>

        {/* 门票类别 */}
        <div>
          <Input
            label="门票类别"
            placeholder="输入门票类别"
            value={formData.category}
            onChange={(e) => handleInputChange('category', e.target.value)}
            error={errors.category}
            list="category-suggestions"
          />
          <datalist id="category-suggestions">
            {commonCategories.map(category => (
              <option key={category} value={category} />
            ))}
          </datalist>
        </div>

        {/* 价格和数量 */}
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="价格 (MON)"
            type="number"
            step="0.01"
            min="0"
            placeholder="0.00"
            value={formData.price}
            onChange={(e) => handleInputChange('price', e.target.value)}
            error={errors.price}
          />
          <Input
            label="总数量"
            type="number"
            min="1"
            placeholder="0"
            value={formData.totalSupply}
            onChange={(e) => handleInputChange('totalSupply', e.target.value)}
            error={errors.totalSupply}
          />
        </div>

        {/* 预览信息 */}
        {selectedMatch && formData.category && formData.price && formData.totalSupply && (
          <div className="bg-gray-50 p-4 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-2">门票类型预览</h4>
            <div className="space-y-1 text-sm text-gray-600">
              <div className="flex items-center justify-between">
                <span>赛事:</span>
                <span className="font-medium">{selectedMatch.homeTeam} vs {selectedMatch.awayTeam}</span>
              </div>
              <div className="flex items-center justify-between">
                <span>类别:</span>
                <span className="font-medium flex items-center">
                  <Ticket className="h-4 w-4 mr-1" />
                  {formData.category}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span>价格:</span>
                <span className="font-medium flex items-center">
                  <DollarSign className="h-4 w-4 mr-1" />
                  {formData.price} MON
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span>数量:</span>
                <span className="font-medium flex items-center">
                  <Hash className="h-4 w-4 mr-1" />
                  {formData.totalSupply} 张
                </span>
              </div>
              <div className="border-t pt-2 mt-2 flex items-center justify-between font-semibold">
                <span>预计收入:</span>
                <span className="text-primary-600">
                  {(parseFloat(formData.price || '0') * parseInt(formData.totalSupply || '0')).toFixed(2)} MON
                </span>
              </div>
            </div>
          </div>
        )}
      </form>

      <ModalFooter>
        <Button
          variant="secondary"
          onClick={handleClose}
          type="button"
        >
          取消
        </Button>
        <Button
          onClick={handleSubmit}
          loading={loading}
          disabled={!formData.matchId || !formData.category || !formData.price || !formData.totalSupply}
          type="button"
        >
          创建门票类型
        </Button>
      </ModalFooter>
    </Modal>
  )
}
