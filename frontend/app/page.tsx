'use client'

import { useState } from 'react'
import { usePrivy } from '@privy-io/react-auth'
import { Plus, Calendar, Ticket, Settings, Users, DollarSign } from 'lucide-react'
import Button from '@/components/ui/Button'
import Card, { CardHeader, CardTitle, CardContent } from '@/components/ui/Card'
import Badge from '@/components/ui/Badge'
import MatchCard from '@/components/matches/MatchCard'
import UserTicketCard from '@/components/tickets/UserTicketCard'
import CreateMatchModal from '@/components/admin/CreateMatchModal'
import CreateTicketTypeModal from '@/components/admin/CreateTicketTypeModal'
import DebugInfo from '@/components/debug/DebugInfo'
import { useTicketing } from '@/hooks/useTicketing'

export default function HomePage() {
  const { user, ready } = usePrivy()
  const {
    loading,
    isAdmin,
    matches,
    userTickets,
    getContractBalance,
  } = useTicketing()

  const [showCreateMatch, setShowCreateMatch] = useState(false)
  const [showCreateTicketType, setShowCreateTicketType] = useState(false)
  const [activeTab, setActiveTab] = useState<'matches' | 'tickets' | 'admin'>('matches')

  // 如果用户未登录，显示欢迎页面
  if (ready && !user) {
    return (
      <div className="text-center py-16">
        <div className="max-w-md mx-auto">
          <div className="text-6xl mb-6">⚽</div>
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            足球买票系统
          </h1>
          <p className="text-gray-600 mb-8">
            基于区块链技术的安全、透明的足球赛事门票销售平台
          </p>
          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
              <div className="bg-white p-4 rounded-lg shadow-sm">
                <Calendar className="h-8 w-8 text-primary-600 mx-auto mb-2" />
                <p className="font-medium">查看赛事</p>
                <p className="text-gray-500">浏览最新的足球赛事</p>
              </div>
              <div className="bg-white p-4 rounded-lg shadow-sm">
                <Ticket className="h-8 w-8 text-primary-600 mx-auto mb-2" />
                <p className="font-medium">购买门票</p>
                <p className="text-gray-500">使用MON代币安全购票</p>
              </div>
              <div className="bg-white p-4 rounded-lg shadow-sm">
                <Settings className="h-8 w-8 text-primary-600 mx-auto mb-2" />
                <p className="font-medium">管理门票</p>
                <p className="text-gray-500">查看和管理您的门票</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // 如果用户已登录，显示主界面
  return (
    <div className="space-y-6">
      {/* 调试信息 */}
      {process.env.NODE_ENV === 'development' && <DebugInfo />}
      
      {/* 欢迎信息 */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              欢迎回来！
            </h1>
            <p className="text-gray-600 mt-1">
              {isAdmin ? '管理员' : '用户'} | {user?.email?.address || user?.phone?.number || '钱包用户'}
            </p>
          </div>
          <div className="flex items-center space-x-2">
            {isAdmin && (
              <Badge variant="warning" className="flex items-center gap-1">
                <Settings className="h-3 w-3" />
                管理员
              </Badge>
            )}
          </div>
        </div>
      </div>

      {/* 标签导航 */}
      <div className="flex space-x-1 bg-white p-1 rounded-lg shadow-sm">
        <button
          onClick={() => setActiveTab('matches')}
          className={`flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-md font-medium transition-colors ${
            activeTab === 'matches'
              ? 'bg-primary-600 text-white'
              : 'text-gray-600 hover:bg-gray-100'
          }`}
        >
          <Calendar className="h-4 w-4" />
          赛事列表
        </button>
        
        <button
          onClick={() => setActiveTab('tickets')}
          className={`flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-md font-medium transition-colors ${
            activeTab === 'tickets'
              ? 'bg-primary-600 text-white'
              : 'text-gray-600 hover:bg-gray-100'
          }`}
        >
          <Ticket className="h-4 w-4" />
          我的门票
          {userTickets.length > 0 && (
            <Badge variant="info" className="text-xs">
              {userTickets.length}
            </Badge>
          )}
        </button>

        {isAdmin && (
          <button
            onClick={() => setActiveTab('admin')}
            className={`flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-md font-medium transition-colors ${
              activeTab === 'admin'
                ? 'bg-primary-600 text-white'
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            <Settings className="h-4 w-4" />
            管理中心
          </button>
        )}
      </div>

      {/* 内容区域 */}
      {activeTab === 'matches' && (
        <div>
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-semibold text-gray-900">
              活跃赛事 ({matches.length})
            </h2>
          </div>

          {loading ? (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {[...Array(6)].map((_, i) => (
                <Card key={i}>
                  <CardContent>
                    <div className="animate-pulse space-y-3">
                      <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                      <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                      <div className="h-4 bg-gray-200 rounded w-2/3"></div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          ) : matches.length > 0 ? (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {matches.map((match) => (
                <MatchCard 
                  key={Number(match.matchId)} 
                  match={match}
                  showAdminActions={isAdmin}
                />
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <Calendar className="h-12 w-12 mx-auto text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">暂无活跃赛事</h3>
              <p className="text-gray-500">
                {isAdmin ? '点击"创建赛事"按钮添加新的足球赛事' : '请稍后查看或联系管理员'}
              </p>
            </div>
          )}
        </div>
      )}

      {activeTab === 'tickets' && (
        <div>
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-semibold text-gray-900">
              我的门票 ({userTickets.length})
            </h2>
          </div>

          {userTickets.length > 0 ? (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {userTickets.map((ticket) => (
                <UserTicketCard key={Number(ticket.ticketId)} ticket={ticket} />
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <Ticket className="h-12 w-12 mx-auto text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">暂无门票</h3>
              <p className="text-gray-500 mb-4">
                您还没有购买任何门票
              </p>
              <Button onClick={() => setActiveTab('matches')}>
                浏览赛事
              </Button>
            </div>
          )}
        </div>
      )}

      {activeTab === 'admin' && isAdmin && (
        <div>
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-semibold text-gray-900">管理中心</h2>
            <div className="flex gap-3">
              <Button
                onClick={() => setShowCreateMatch(true)}
                className="flex items-center gap-2"
              >
                <Plus className="h-4 w-4" />
                创建赛事
              </Button>
              <Button
                onClick={() => setShowCreateTicketType(true)}
                variant="secondary"
                className="flex items-center gap-2"
              >
                <Plus className="h-4 w-4" />
                创建门票类型
              </Button>
            </div>
          </div>

          {/* 管理统计 */}
          <div className="grid gap-6 md:grid-cols-3 mb-8">
            <Card>
              <CardHeader>
                <CardTitle className="text-sm font-medium text-gray-600 flex items-center">
                  <Calendar className="h-4 w-4 mr-2" />
                  总赛事数
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-gray-900">{matches.length}</div>
                <p className="text-xs text-gray-500 mt-1">活跃赛事</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-sm font-medium text-gray-600 flex items-center">
                  <Users className="h-4 w-4 mr-2" />
                  总门票数
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-gray-900">
                  {userTickets.filter(t => t.status === 1).length}
                </div>
                <p className="text-xs text-gray-500 mt-1">已售出门票</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-sm font-medium text-gray-600 flex items-center">
                  <DollarSign className="h-4 w-4 mr-2" />
                  合约余额
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-gray-900">-- MON</div>
                <p className="text-xs text-gray-500 mt-1">待提取收入</p>
              </CardContent>
            </Card>
          </div>

          {/* 赛事管理列表 */}
          <div>
            <h3 className="text-lg font-medium text-gray-900 mb-4">赛事管理</h3>
            {matches.length > 0 ? (
              <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {matches.map((match) => (
                  <MatchCard 
                    key={Number(match.matchId)} 
                    match={match}
                    showAdminActions={true}
                  />
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <Calendar className="h-8 w-8 mx-auto text-gray-400 mb-4" />
                <p className="text-gray-500">暂无赛事，点击"创建赛事"开始</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* 模态框 */}
      <CreateMatchModal
        isOpen={showCreateMatch}
        onClose={() => setShowCreateMatch(false)}
      />
      
      <CreateTicketTypeModal
        isOpen={showCreateTicketType}
        onClose={() => setShowCreateTicketType(false)}
        matches={matches}
      />
    </div>
  )
}
