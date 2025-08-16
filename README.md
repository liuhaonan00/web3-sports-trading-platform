# Web3 足球买票系统

一个基于智能合约的足球赛事门票销售系统，支持使用MON代币购买门票和退票。

## 主要功能

- 🔐 **角色管理**: Admin(管理员) 和 User(用户) 两种角色
- ⚽ **赛事管理**: 管理员可以创建足球赛事，设置比赛信息
- 🎫 **门票管理**: 支持多种门票类型（VIP、普通席、看台等）
- 💰 **MON代币支付**: 使用MON代币购买门票
- 🔄 **退票功能**: 比赛开始前1小时可申请退票

## 快速开始

### 编译合约
```bash
cd solidity
forge build
```

### 运行测试
```bash
forge test
```

### 部署合约
```bash
# 设置环境变量
export PRIVATE_KEY="your_private_key"
export MON_TOKEN_ADDRESS="mon_token_address"

# 部署到Monad测试网
forge script script/DeployTicketingSystem.s.sol --rpc-url https://testnet-rpc.monad.xyz --broadcast
```

### 运行演示
```bash
forge script script/Demo.s.sol --fork-url https://testnet-rpc.monad.xyz
```

## 详细文档

查看 [TICKETING_SYSTEM_GUIDE.md](./sports-trading-platform/TICKETING_SYSTEM_GUIDE.md) 获取完整的使用指南。

## 合约地址

- **Monad Testnet**: `待部署`

## 项目结构

```
sports-trading-platform/
├── src/
│   └── TicketingSystem.sol      # 主合约
├── test/
│   └── TicketingSystem.t.sol    # 测试合约
├── script/
│   ├── DeployTicketingSystem.s.sol  # 部署脚本
│   └── Demo.s.sol               # 演示脚本
└── TICKETING_SYSTEM_GUIDE.md    # 详细使用指南
```

## 技术栈

- **Solidity ^0.8.13**
- **Foundry** (开发框架)
- **OpenZeppelin** (安全库)
- **Monad Testnet** (部署网络)