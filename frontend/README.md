# 足球买票系统前端

基于 Next.js + React + Ethers.js + Privy 的足球赛事门票销售系统前端界面。

## 🚀 功能特性

### 用户功能
- 🔐 **Privy 登录** - 支持钱包、邮箱、手机号登录
- ⚽ **浏览赛事** - 查看所有活跃的足球赛事
- 🎫 **购买门票** - 使用原生MON代币购买门票
- 📱 **管理门票** - 查看已购买的门票，支持退票
- 💰 **余额显示** - 实时显示钱包MON余额

### 管理员功能
- 👑 **管理面板** - 专用的管理员界面
- 📅 **创建赛事** - 添加新的足球赛事
- 🎟️ **门票管理** - 创建不同类型的门票
- 📊 **数据统计** - 查看赛事和销售统计
- ⚙️ **赛事控制** - 激活/停用赛事

## 🛠️ 技术栈

- **Framework**: Next.js 14 + TypeScript
- **UI**: Tailwind CSS + 自定义组件
- **认证**: Privy (支持多种登录方式)
- **区块链**: Ethers.js + Wagmi
- **状态管理**: React Hooks + Context
- **通知**: React Hot Toast
- **图标**: Lucide React

## 📦 安装和运行

### 1. 安装依赖

```bash
npm install
# 或
yarn install
# 或
pnpm install
```

### 2. 环境配置

复制 `env.example` 为 `.env.local` 并配置：

```bash
cp env.example .env.local
```

填入以下配置：

```env
# Privy应用ID (从 https://dashboard.privy.io 获取)
NEXT_PUBLIC_PRIVY_APP_ID=your_privy_app_id_here

# 合约地址 (已部署的TicketingSystemNative合约)
NEXT_PUBLIC_TICKETING_CONTRACT_ADDRESS=0x8587382627bDee45B42967b920f734b0ddA931C3

# Monad测试网配置 (通常不需要修改)
NEXT_PUBLIC_CHAIN_ID=10143
NEXT_PUBLIC_RPC_URL=https://testnet-rpc.monad.xyz
NEXT_PUBLIC_CHAIN_NAME=Monad Testnet
NEXT_PUBLIC_NATIVE_CURRENCY_NAME=MON
NEXT_PUBLIC_NATIVE_CURRENCY_SYMBOL=MON
NEXT_PUBLIC_NATIVE_CURRENCY_DECIMALS=18
NEXT_PUBLIC_BLOCK_EXPLORER_URL=https://testnet.monadexplorer.com
```

### 3. 启动开发服务器

```bash
npm run dev
# 或
yarn dev
# 或
pnpm dev
```

访问 [http://localhost:3000](http://localhost:3000)

## 🔧 Privy 配置

1. 访问 [Privy Dashboard](https://dashboard.privy.io)
2. 创建新应用或使用现有应用
3. 配置登录方式：
   - ✅ Wallet (钱包登录)
   - ✅ Email (邮箱登录)
   - ✅ SMS (手机号登录)
4. 添加允许的域名：`http://localhost:3000`
5. 复制 App ID 到环境变量

## 📱 界面预览

### 主页面
- 登录前：欢迎页面 + 功能介绍
- 登录后：标签式导航 (赛事/门票/管理)

### 赛事页面
- 卡片式展示所有活跃赛事
- 支持查看门票类型和剩余数量
- 一键购票功能

### 我的门票
- 展示用户拥有的所有门票
- 支持门票退款 (条件允许时)
- 实时状态更新

### 管理员面板
- 统计数据仪表板
- 创建赛事和门票类型
- 赛事状态管理

## 🎨 UI 组件

### 基础组件
- `Button` - 多种样式的按钮组件
- `Card` - 卡片布局组件
- `Input` - 表单输入组件
- `Badge` - 状态标签组件
- `Modal` - 模态框组件

### 业务组件
- `MatchCard` - 赛事卡片
- `UserTicketCard` - 用户门票卡片
- `TicketPurchaseModal` - 购票模态框
- `CreateMatchModal` - 创建赛事模态框
- `CreateTicketTypeModal` - 创建门票类型模态框

## 🔄 状态管理

### useTicketing Hook
- 管理所有合约交互逻辑
- 统一的加载状态处理
- 自动错误处理和通知

### useContract Hook
- Ethers.js 合约实例管理
- 只读/可写合约分离
- Signer 管理

## 🎯 开发指南

### 添加新功能
1. 在 `hooks/useTicketing.ts` 中添加合约交互逻辑
2. 创建对应的 UI 组件
3. 在页面中集成新组件

### 样式定制
- 主色调在 `tailwind.config.js` 中配置
- 全局样式在 `app/globals.css` 中定义
- 组件样式使用 Tailwind 类名

### 错误处理
- 合约错误通过 React Hot Toast 显示
- 网络错误自动重试
- 用户友好的错误信息

## 🚦 部署

### 构建生产版本

```bash
npm run build
npm start
```

### 环境变量

生产环境需要配置：
- `NEXT_PUBLIC_PRIVY_APP_ID`
- `NEXT_PUBLIC_TICKETING_CONTRACT_ADDRESS`
- 其他网络配置 (如果部署到不同网络)

## 📞 常见问题

### Q: 无法连接钱包
A: 确保安装了 MetaMask 或其他兼容钱包，并已连接到 Monad 测试网

### Q: 交易失败
A: 检查钱包是否有足够的 MON 代币支付 gas 费用和门票费用

### Q: 看不到管理员功能
A: 确保您的钱包地址是合约的管理员或拥有者

### Q: Privy 登录失败
A: 检查 Privy App ID 是否正确配置，域名是否已添加到白名单

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
