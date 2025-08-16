# 🚀 快速启动指南

## 1. 前置条件

### 必需工具
- ✅ Node.js 18+ 
- ✅ npm/yarn/pnpm
- ✅ MetaMask 或其他 Web3 钱包

### 准备工作
- ✅ 注册 [Privy 账户](https://dashboard.privy.io)
- ✅ 钱包中有 Monad 测试网 MON 代币
- ✅ 已部署的 TicketingSystemNative 合约

## 2. 快速部署 (5分钟)

### 步骤 1: 克隆和安装
```bash
cd frontend
npm install
```

### 步骤 2: 配置 Privy
1. 访问 [Privy Dashboard](https://dashboard.privy.io)
2. 创建新应用
3. 配置登录方式：钱包 + 邮箱 + 手机
4. 添加域名：`http://localhost:3000`
5. 复制 App ID

### 步骤 3: 环境配置
```bash
cp env.example .env.local
```

编辑 `.env.local`：
```env
NEXT_PUBLIC_PRIVY_APP_ID=你的_privy_app_id
NEXT_PUBLIC_TICKETING_CONTRACT_ADDRESS=0x8587382627bDee45B42967b920f734b0ddA931C3
```

### 步骤 4: 启动
```bash
npm run dev
```

🎉 访问 http://localhost:3000

## 3. 功能测试流程

### 用户流程测试
1. **连接钱包**
   - 点击"连接钱包"
   - 选择 MetaMask
   - 确认连接 Monad 测试网

2. **浏览赛事**
   - 查看"赛事列表"标签
   - 点击"查看门票"按钮
   - 查看门票类型和价格

3. **购买门票**
   - 点击"购买门票"
   - 选择门票类型
   - 确认支付 MON 代币

4. **管理门票**
   - 切换到"我的门票"标签
   - 查看已购买的门票
   - 尝试退票功能

### 管理员流程测试
1. **获取管理员权限**
   - 使用部署合约的钱包地址登录
   - 确认看到"管理员"标识

2. **创建赛事**
   - 切换到"管理中心"标签
   - 点击"创建赛事"
   - 填写赛事信息并提交

3. **创建门票类型**
   - 点击"创建门票类型"
   - 选择已创建的赛事
   - 设置门票类别、价格和数量

4. **管理赛事**
   - 查看统计数据
   - 激活/停用赛事
   - 查看销售情况

## 4. 常见问题解决

### 🔧 钱包连接问题
```bash
# 确保钱包已连接到 Monad 测试网
网络名称: Monad Testnet
RPC URL: https://testnet-rpc.monad.xyz
链ID: 10143
货币符号: MON
区块浏览器: https://testnet.monadexplorer.com
```

### 🔧 Privy 配置问题
- 确认 App ID 正确
- 检查域名白名单
- 验证登录方式配置

### 🔧 交易失败问题
- 检查 MON 代币余额
- 确认 gas 费用充足
- 验证合约地址正确

### 🔧 管理员权限问题
- 确认使用部署合约的钱包
- 检查合约 `isAdmin()` 函数
- 验证 `owner()` 地址

## 5. 开发技巧

### 调试工具
```javascript
// 在浏览器控制台中检查合约状态
console.log(await window.ethereum.request({
  method: 'eth_call',
  params: [{
    to: '0x8587382627bDee45B42967b920f734b0ddA931C3',
    data: '0x...' // 合约方法调用数据
  }, 'latest']
}))
```

### 网络切换
```javascript
// 切换到 Monad 测试网
await window.ethereum.request({
  method: 'wallet_switchEthereumChain',
  params: [{ chainId: '0x27C7' }], // 10143 in hex
})
```

### 余额查询
```javascript
// 查询 MON 余额
const balance = await window.ethereum.request({
  method: 'eth_getBalance',
  params: ['你的钱包地址', 'latest']
})
console.log(parseInt(balance, 16) / 1e18, 'MON')
```

## 6. 生产部署

### Vercel 部署 (推荐)
1. 推送代码到 GitHub
2. 在 Vercel 导入项目
3. 配置环境变量
4. 自动部署

### 环境变量配置
```env
NEXT_PUBLIC_PRIVY_APP_ID=生产环境_app_id
NEXT_PUBLIC_TICKETING_CONTRACT_ADDRESS=主网合约地址
# 其他配置根据目标网络调整
```

## 7. 性能优化

### 图片优化
- 使用 Next.js Image 组件
- 配置 CDN 加速

### 包大小优化
```bash
npm run build
npm run analyze # 分析包大小
```

### 缓存策略
- 合约调用结果缓存
- 静态资源 CDN 缓存

## 8. 监控和分析

### 错误监控
- 集成 Sentry
- 监控交易失败率

### 用户分析
- 集成 Google Analytics
- 跟踪用户行为

---

## 🆘 需要帮助？

- 📧 邮件支持
- 💬 技术交流群
- 📖 详细文档：`README.md`
- 🐛 问题反馈：GitHub Issues

---

**祝您使用愉快！⚽🎫**
