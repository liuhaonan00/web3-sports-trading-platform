# Web3 足球买票系统

一个基于智能合约的足球赛事门票销售系统，支持使用MON代币购买门票和退票。

## 主要功能

- 🔐 **角色管理**: Admin(管理员) 和 User(用户) 两种角色
- ⚽ **赛事管理**: 管理员可以创建足球赛事，设置比赛信息
- 🎫 **门票管理**: 支持多种门票类型（VIP、普通席、看台等）
- 💰 **MON代币支付**: 使用MON代币购买门票
- 🔄 **退票功能**: 比赛开始前1小时可申请退票

## 快速开始

### 🚀 原生MON代币版本（推荐）

```bash
cd solidity

# 一键部署原生代币版本
./quick_deploy_native.sh

# 交互测试
./interact_native.sh <合约地址>
```

### 🪙 ERC-20代币版本（测试用）

```bash
cd solidity

# 一键部署ERC-20版本（包含MockMON代币）
./quick_deploy.sh

# 交互测试
./interact_ticketing.sh <MON_TOKEN_ADDRESS> <TICKETING_SYSTEM_ADDRESS>
```

### 📋 分步部署（高级用户）

```bash
# 原生代币版本
./deploy_native.sh

# ERC-20版本
./deploy_ticketing.sh
```

### 🧪 运行测试

```bash
forge test
```

### 📚 查看详细指南

```bash
# 原生代币版本指南
cat NATIVE_VERSION_GUIDE.md

# ERC-20版本指南  
cat SIMPLE_DEPLOY.md
```

## 详细文档

查看 [TICKETING_SYSTEM_GUIDE.md](./solidity/TICKETING_SYSTEM_GUIDE.md) 获取完整的使用指南。

## 合约地址

- **Monad Testnet**: `待部署`

## 项目结构

```
solidity/
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