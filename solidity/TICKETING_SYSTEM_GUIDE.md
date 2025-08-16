# 足球买票系统智能合约使用指南

## 概述

这是一个基于以太坊的足球比赛门票销售系统智能合约，支持管理员管理赛事和门票，用户使用MON代币购买和退票。

## 主要功能

### 1. 用户角色管理
- **Admin**: 管理员，可以创建赛事、设置门票类型和价格
- **User**: 普通用户，可以购买门票和申请退票

### 2. 赛事管理 (仅限Admin)
- 创建新的足球赛事
- 设置比赛时间、队伍、场地等信息
- 激活/停用赛事

### 3. 门票管理 (仅限Admin)
- 为每场比赛创建不同类型的门票（VIP、普通席等）
- 设置门票价格（以MON代币计算）
- 设置门票数量限制

### 4. 购票功能 (用户)
- 浏览活跃的赛事
- 查看不同类型门票的价格和剩余数量
- 使用MON代币购买门票

### 5. 退票功能 (用户)
- 在比赛开始前1小时可以申请退票
- 全额退还MON代币（可设置手续费）

## 合约部署

### 前提条件
1. 安装 Foundry
2. 准备 MON 代币合约地址
3. 准备部署账户的私钥

### 部署步骤

1. **设置环境变量**
```bash
export PRIVATE_KEY="your_private_key_here"
export MON_TOKEN_ADDRESS="mon_token_contract_address"
```

2. **编译合约**
```bash
forge build
```

3. **运行测试**
```bash
forge test
```

4. **部署到Monad测试网**
```bash
forge script script/DeployTicketingSystem.s.sol --rpc-url https://testnet-rpc.monad.xyz --broadcast --verify
```

## 主要函数说明

### 管理员函数

#### `addAdmin(address _admin)`
添加新的管理员

#### `createMatch(string _homeTeam, string _awayTeam, uint256 _matchTime, string _venue)`
创建新的足球赛事
- `_homeTeam`: 主队名称
- `_awayTeam`: 客队名称  
- `_matchTime`: 比赛时间（Unix时间戳）
- `_venue`: 比赛场地

#### `createTicketType(uint256 _matchId, string _category, uint256 _price, uint256 _totalSupply)`
为指定赛事创建门票类型
- `_matchId`: 赛事ID
- `_category`: 门票类别（如"VIP", "普通席"）
- `_price`: 价格（MON代币，包含18位小数）
- `_totalSupply`: 总供应量

#### `setMatchStatus(uint256 _matchId, bool _isActive)`
设置赛事状态（激活/停用）

#### `withdrawMON(uint256 _amount)`
提取合约中的MON代币收入

### 用户函数

#### `purchaseTicket(uint256 _typeId)`
购买指定类型的门票
- 需要先授权MON代币给合约
- 确保余额充足

#### `refundTicket(uint256 _ticketId)`
申请退票
- 只能退自己的门票
- 比赛开始前1小时内不能退票

### 查询函数

#### `getActiveMatches()`
获取所有活跃的赛事列表

#### `getMatchTicketTypes(uint256 _matchId)`
获取指定赛事的所有门票类型

#### `getUserTickets(address _user)`
获取用户拥有的所有门票

#### `isAdmin(address _address)`
检查地址是否为管理员

#### `getContractBalance()`
获取合约的MON代币余额

## 使用示例

### 1. 管理员创建赛事和门票

```solidity
// 创建赛事
ticketingSystem.createMatch(
    "Real Madrid",
    "Barcelona", 
    1640995200, // 2022-01-01 00:00:00 UTC
    "Santiago Bernabeu"
);

// 创建VIP门票
ticketingSystem.createTicketType(
    1, // matchId
    "VIP",
    200 * 10**18, // 200 MON
    50 // 50张票
);

// 创建普通门票
ticketingSystem.createTicketType(
    1, // matchId
    "Regular",
    100 * 10**18, // 100 MON
    200 // 200张票
);
```

### 2. 用户购买门票

```solidity
// 先授权MON代币
monToken.approve(address(ticketingSystem), 200 * 10**18);

// 购买VIP门票
ticketingSystem.purchaseTicket(1); // typeId = 1
```

### 3. 用户退票

```solidity
// 退票 (ticketId = 1)
ticketingSystem.refundTicket(1);
```

## 安全特性

1. **访问控制**: 只有管理员可以创建赛事和门票类型
2. **重入保护**: 购票和退票函数有重入保护
3. **时间限制**: 只能在比赛开始前购票和退票
4. **余额检查**: 购票前检查用户MON代币余额和授权额度
5. **库存管理**: 防止超卖，实时更新剩余票数

## 事件日志

合约会发出以下事件用于前端监听：

- `MatchCreated`: 赛事创建
- `TicketTypeCreated`: 门票类型创建  
- `TicketPurchased`: 门票购买
- `TicketRefunded`: 门票退款
- `AdminAdded`: 管理员添加
- `AdminRemoved`: 管理员移除
- `MatchStatusChanged`: 赛事状态变更

## 注意事项

1. **MON代币**: 确保在部署前获取正确的MON代币合约地址
2. **时间设置**: 所有时间都使用Unix时间戳
3. **精度**: MON代币使用18位小数精度
4. **Gas费用**: 在Monad测试网上部署和交互
5. **测试**: 在主网部署前务必在测试网充分测试

## 故障排除

### 常见错误

1. **"Insufficient MON token balance"**: 用户MON代币余额不足
2. **"Insufficient allowance"**: 需要先授权MON代币给合约
3. **"Tickets sold out"**: 该类型门票已售完
4. **"Only admin can perform this action"**: 非管理员尝试执行管理员功能
5. **"Cannot refund within 1 hour of match time"**: 比赛开始前1小时内不能退票

### 调试建议

1. 使用 `forge test -vvv` 运行详细测试
2. 检查事件日志确认交易状态
3. 使用区块链浏览器查看交易详情
4. 确认所有权限和授权设置正确
