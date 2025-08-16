# 原生MON代币版本使用指南

## 🎯 概述

这是支持原生MON代币的足球买票系统版本。与ERC-20版本不同，这个版本使用Monad测试网的原生MON代币进行交易，就像以太坊使用ETH一样。

## 🔄 与ERC-20版本的主要区别

| 特性 | ERC-20版本 | 原生代币版本 |
|------|-----------|-------------|
| 代币类型 | MockMON ERC-20 | 原生MON代币 |
| 购买门票 | `approve()` + `transferFrom()` | 直接发送MON (`msg.value`) |
| 退票 | ERC-20 `transfer()` | 原生代币 `transfer()` |
| 部署复杂度 | 需要部署两个合约 | 只需部署一个合约 |
| Gas费用 | 稍高（两次交易） | 稍低（一次交易） |

## 🚀 快速开始

### 1. 一键部署（推荐）

```bash
./quick_deploy_native.sh
```

### 2. 分步部署

```bash
./deploy_native.sh
```

### 3. 交互测试

```bash
./interact_native.sh <合约地址>
```

## 📁 新增文件

- `TicketingSystemNative.sol` - 支持原生代币的主合约
- `TicketingSystemNative.t.sol` - 对应的测试合约
- `deploy_native.sh` - 原生版本部署脚本
- `quick_deploy_native.sh` - 一键部署脚本
- `interact_native.sh` - 交互脚本

## 🔧 关键功能差异

### 购买门票

**ERC-20版本:**
```bash
# 1. 先授权
cast send $MON_ADDRESS "approve(address,uint256)" $TICKETING_ADDRESS 1000000000000000000 --account monad-deployer

# 2. 再购买
cast send $TICKETING_ADDRESS "purchaseTicket(uint256)" 1 --account monad-deployer
```

**原生代币版本:**
```bash
# 一步完成，直接发送MON
cast send $TICKETING_ADDRESS "purchaseTicket(uint256)" 1 \
  --value 1000000000000000000 --account monad-deployer
```

### 价格设置

原生代币版本的价格以wei为单位：

- 1 MON = 1,000,000,000,000,000,000 wei
- 0.1 MON = 100,000,000,000,000,000 wei
- 0.01 MON = 10,000,000,000,000,000 wei

## 💡 使用示例

### 完整流程演示

```bash
# 1. 部署合约
./quick_deploy_native.sh

# 假设合约地址为: 0x123...
CONTRACT_ADDRESS="0x123..."

# 2. 创建赛事
cast send $CONTRACT_ADDRESS "createMatch(string,string,uint256,string)" \
  "Real Madrid" "Barcelona" $(($(date +%s) + 604800)) "Santiago Bernabeu" \
  --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz

# 3. 创建VIP门票 (价格: 2 MON)
cast send $CONTRACT_ADDRESS "createTicketType(uint256,string,uint256,uint256)" \
  1 "VIP" 2000000000000000000 50 \
  --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz

# 4. 创建普通门票 (价格: 1 MON)
cast send $CONTRACT_ADDRESS "createTicketType(uint256,string,uint256,uint256)" \
  1 "Regular" 1000000000000000000 100 \
  --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz

# 5. 购买VIP门票 (发送2 MON)
cast send $CONTRACT_ADDRESS "purchaseTicket(uint256)" 1 \
  --value 2000000000000000000 --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz

# 6. 查看我的门票
cast call $CONTRACT_ADDRESS "getUserTickets(address)" 0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a \
  --rpc-url https://testnet-rpc.monad.xyz

# 7. 退票 (如果需要)
cast send $CONTRACT_ADDRESS "refundTicket(uint256)" 1 \
  --account monad-deployer --rpc-url https://testnet-rpc.monad.xyz
```

## 🔍 合约特殊功能

### 1. 自动退还多余代币

如果发送的MON超过门票价格，合约会自动退还多余部分：

```solidity
// 如果发送1.5 MON购买1 MON的门票，会自动退还0.5 MON
function purchaseTicket(uint256 _typeId) external payable {
    // ...
    if (msg.value > price) {
        payable(msg.sender).transfer(msg.value - price);
    }
    // ...
}
```

### 2. 直接接收代币

合约可以直接接收原生MON代币：

```bash
# 直接向合约发送MON (用于紧急情况或捐赠)
cast send $CONTRACT_ADDRESS --value 1000000000000000000 --account monad-deployer
```

### 3. 紧急提取功能

合约拥有者可以提取所有资金：

```bash
cast send $CONTRACT_ADDRESS "emergencyWithdraw()" --account monad-deployer
```

## ⚠️ 注意事项

### 1. 价格计算

使用wei单位时要注意精度：

```bash
# 正确：1 MON
--value 1000000000000000000

# 错误：实际是0.000000000000000001 MON
--value 1
```

### 2. 余额检查

确保钱包有足够的原生MON代币：

```bash
# 检查余额
cast balance 0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a --rpc-url https://testnet-rpc.monad.xyz
```

### 3. Gas费用

原生代币转账需要预留gas费用，不要把所有MON都用于购票。

## 🆚 版本选择建议

**使用原生代币版本当:**
- ✅ 你有充足的原生MON测试代币
- ✅ 希望更接近真实的支付体验
- ✅ 需要更低的gas费用
- ✅ 想要更简单的部署流程

**使用ERC-20版本当:**
- ✅ 你缺乏原生MON测试代币
- ✅ 需要完全可控的测试环境
- ✅ 想模拟ERC-20代币交易
- ✅ 进行功能开发和测试

## 🛠️ 开发和测试

### 运行测试

```bash
# 只测试原生版本
forge test --match-contract TicketingSystemNativeTest

# 对比两个版本
forge test --match-contract TicketingSystem
```

### 部署到测试网

```bash
# 确保有原生MON代币
cast balance 0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a --rpc-url https://testnet-rpc.monad.xyz

# 部署
./quick_deploy_native.sh
```

## 🔗 相关链接

- [Monad测试网浏览器](https://testnet.monadexplorer.com/)
- [Monad测试网水龙头](https://www.testnet-monad.xyz/)
- [原版ERC-20指南](./TICKETING_SYSTEM_GUIDE.md)
