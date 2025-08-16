import { InputHTMLAttributes, forwardRef } from 'react'
import { cn } from '@/lib/utils'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  helpText?: string
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, label, error, helpText, id, ...props }, ref) => {
    const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`

    return (
      <div className="space-y-1">
        {label && (
          <label htmlFor={inputId} className="label">
            {label}
          </label>
        )}
        
        <input
          ref={ref}
          id={inputId}
          className={cn(
            'input-field',
            error && 'border-error-500 focus:ring-error-500 focus:border-error-500',
            className
          )}
          {...props}
        />
        
        {error && (
          <p className="text-sm text-error-600">
            {error}
          </p>
        )}
        
        {helpText && !error && (
          <p className="text-sm text-gray-500">
            {helpText}
          </p>
        )}
      </div>
    )
  }
)

Input.displayName = 'Input'

export default Input
