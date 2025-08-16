import { clsx, type ClassValue } from 'clsx'

// 简单的类名合并函数，如果需要可以后续集成 tailwind-merge
export function cn(...inputs: ClassValue[]) {
  return clsx(inputs)
}
