import { useState } from 'react'
import { Calendar, MapPin, Users } from 'lucide-react'
import Modal, { ModalFooter } from '@/components/ui/Modal'
import Button from '@/components/ui/Button'
import Input from '@/components/ui/Input'
import { useTicketing } from '@/hooks/useTicketing'
import toast from 'react-hot-toast'

interface CreateMatchModalProps {
  isOpen: boolean
  onClose: () => void
}

interface FormData {
  homeTeam: string
  awayTeam: string
  matchDateTime: string
  venue: string
}

export default function CreateMatchModal({ isOpen, onClose }: CreateMatchModalProps) {
  const { createMatch, loading } = useTicketing()
  const [formData, setFormData] = useState<FormData>({
    homeTeam: '',
    awayTeam: '',
    matchDateTime: '',
    venue: ''
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

    if (!formData.homeTeam.trim()) {
      newErrors.homeTeam = '请输入主队名称'
    }
    if (!formData.awayTeam.trim()) {
      newErrors.awayTeam = '请输入客队名称'
    }
    if (!formData.matchDateTime) {
      newErrors.matchDateTime = '请选择比赛时间'
    } else {
      const matchDate = new Date(formData.matchDateTime)
      if (matchDate <= new Date()) {
        newErrors.matchDateTime = '比赛时间必须是未来时间'
      }
    }
    if (!formData.venue.trim()) {
      newErrors.venue = '请输入比赛场地'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return

    const matchDate = new Date(formData.matchDateTime)
    const success = await createMatch(
      formData.homeTeam.trim(),
      formData.awayTeam.trim(),
      matchDate,
      formData.venue.trim()
    )

    if (success) {
      handleClose()
    }
  }

  const handleClose = () => {
    setFormData({
      homeTeam: '',
      awayTeam: '',
      matchDateTime: '',
      venue: ''
    })
    setErrors({})
    onClose()
  }

  // 设置最小日期时间为当前时间后1小时
  const getMinDateTime = () => {
    const now = new Date()
    now.setHours(now.getHours() + 1)
    return now.toISOString().slice(0, 16)
  }

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="创建新赛事"
      size="md"
    >
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* 队伍信息 */}
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="主队"
            placeholder="输入主队名称"
            value={formData.homeTeam}
            onChange={(e) => handleInputChange('homeTeam', e.target.value)}
            error={errors.homeTeam}
          />
          <Input
            label="客队"
            placeholder="输入客队名称"
            value={formData.awayTeam}
            onChange={(e) => handleInputChange('awayTeam', e.target.value)}
            error={errors.awayTeam}
          />
        </div>

        {/* 比赛时间 */}
        <Input
          label="比赛时间"
          type="datetime-local"
          value={formData.matchDateTime}
          min={getMinDateTime()}
          onChange={(e) => handleInputChange('matchDateTime', e.target.value)}
          error={errors.matchDateTime}
          helpText="请选择未来的时间"
        />

        {/* 比赛场地 */}
        <Input
          label="比赛场地"
          placeholder="输入比赛场地"
          value={formData.venue}
          onChange={(e) => handleInputChange('venue', e.target.value)}
          error={errors.venue}
        />

        {/* 预览信息 */}
        {formData.homeTeam && formData.awayTeam && (
          <div className="bg-gray-50 p-4 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-2">赛事预览</h4>
            <div className="space-y-1 text-sm text-gray-600">
              <div className="flex items-center">
                <Users className="h-4 w-4 mr-2" />
                <span className="font-medium">{formData.homeTeam || '主队'} vs {formData.awayTeam || '客队'}</span>
              </div>
              {formData.matchDateTime && (
                <div className="flex items-center">
                  <Calendar className="h-4 w-4 mr-2" />
                  <span>{new Date(formData.matchDateTime).toLocaleDateString('zh-CN', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                  })}</span>
                </div>
              )}
              {formData.venue && (
                <div className="flex items-center">
                  <MapPin className="h-4 w-4 mr-2" />
                  <span>{formData.venue}</span>
                </div>
              )}
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
          type="button"
        >
          创建赛事
        </Button>
      </ModalFooter>
    </Modal>
  )
}
