import { Fragment } from 'react'
import { X } from 'lucide-react'
import Button from './Button'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  children: React.ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

export default function Modal({ isOpen, onClose, title, children, size = 'md' }: ModalProps) {
  if (!isOpen) return null

  const sizeClasses = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl'
  }

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        {/* 背景遮罩 */}
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
          onClick={onClose}
        />
        
        {/* 模态框内容 */}
        <div className={`relative w-full ${sizeClasses[size]} bg-white rounded-lg shadow-xl`}>
          {/* 头部 */}
          <div className="flex items-center justify-between p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-900">
              {title}
            </h2>
            <Button
              variant="outline"
              size="sm"
              onClick={onClose}
              className="!p-2 border-none hover:bg-gray-100"
            >
              <X className="h-4 w-4" />
            </Button>
          </div>
          
          {/* 内容 */}
          <div className="p-6">
            {children}
          </div>
        </div>
      </div>
    </div>
  )
}

export const ModalFooter = ({ children }: { children: React.ReactNode }) => (
  <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
    {children}
  </div>
)
