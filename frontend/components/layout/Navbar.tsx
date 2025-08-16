'use client'

import { useLogin, useLogout, usePrivy } from '@privy-io/react-auth'
import { useTicketing } from '@/hooks/useTicketing'
import { formatMON } from '@/config/constants'
import Button from '@/components/ui/Button'
import Badge from '@/components/ui/Badge'
import { Wallet, LogOut, Shield, User } from 'lucide-react'
import { useState, useEffect } from 'react'

export default function Navbar() {
  const { login } = useLogin()
  const { logout } = useLogout()
  const { user, ready } = usePrivy()
  const { isAdmin } = useTicketing()
  const [balance, setBalance] = useState<string>('0')

  // 获取钱包余额
  useEffect(() => {
    async function fetchBalance() {
      if (user?.wallet?.address && window.ethereum) {
        try {
          const balance = await window.ethereum.request({
            method: 'eth_getBalance',
            params: [user.wallet.address, 'latest']
          })
          setBalance(formatMON(BigInt(balance)))
        } catch (error) {
          console.error('Error fetching balance:', error)
        }
      }
    }

    fetchBalance()
  }, [user?.wallet?.address])

  const shortenAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`
  }

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <h1 className="text-xl font-bold text-primary-600">
                ⚽ 足球买票系统
              </h1>
            </div>
          </div>

          {/* 用户信息和登录按钮 */}
          <div className="flex items-center space-x-4">
            {ready && user ? (
              <>
                {/* 管理员标识 */}
                {isAdmin && (
                  <Badge variant="warning" className="flex items-center gap-1">
                    <Shield className="h-3 w-3" />
                    管理员
                  </Badge>
                )}

                {/* 钱包信息 */}
                {user.wallet?.address && (
                  <div className="flex items-center space-x-2 text-sm text-gray-600">
                    <Wallet className="h-4 w-4" />
                    <span>{shortenAddress(user.wallet.address)}</span>
                    <Badge variant="info">
                      {balance} MON
                    </Badge>
                  </div>
                )}

                {/* 用户信息 */}
                <div className="flex items-center space-x-2 text-sm text-gray-600">
                  <User className="h-4 w-4" />
                  <span>
                    {user.email?.address || 
                     user.phone?.number || 
                     (user.wallet?.address && shortenAddress(user.wallet.address)) ||
                     '未知用户'}
                  </span>
                </div>

                {/* 登出按钮 */}
                <Button
                  variant="outline"
                  size="sm"
                  onClick={logout}
                  className="flex items-center gap-2"
                >
                  <LogOut className="h-4 w-4" />
                  登出
                </Button>
              </>
            ) : (
              /* 登录按钮 */
              <Button
                onClick={login}
                className="flex items-center gap-2"
              >
                <Wallet className="h-4 w-4" />
                连接钱包
              </Button>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}
