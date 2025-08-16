# 获取 Monad 测试网代币指南

## 您的钱包信息
- **地址**: `0xB6dD45e103b2041218EaB0EFF90164992206d001`
- **当前余额**: 0 MON (测试代币)
- **网络**: Monad Testnet (Chain ID: 10143)

## 获取测试代币的方法

### 方法 1: 官方渠道
1. 访问 [Monad 官方文档](https://docs.monad.xyz)
2. 查找测试网水龙头部分
3. 或者加入 Monad 官方 Discord 服务器，在相关频道请求测试代币

### 方法 2: 通过 Cast 命令（如果有可用的水龙头合约）
```bash
# 检查余额
cast balance 0xB6dD45e103b2041218EaB0EFF90164992206d001 --rpc-url https://testnet-rpc.monad.xyz

# 将余额转换为更易读的格式（以太为单位）
cast balance 0xB6dD45e103b2041218EaB0EFF90164992206d001 --rpc-url https://testnet-rpc.monad.xyz | cast to-unit ether
```

### 方法 3: 联系开发者社区
- 在 Monad 的开发者频道询问
- 查看是否有其他开发者可以分享少量测试代币

## 获取代币后的验证步骤

1. **检查余额**:
```bash
cast balance 0xB6dD45e103b2041218EaB0EFF90164992206d001 --rpc-url https://testnet-rpc.monad.xyz
```

2. **重新部署合约**:
```bash
forge create src/Counter.sol:Counter --account monad-deployer --broadcast
```

## 常见问题

### Q: 需要多少测试代币？
A: 通常几个测试代币就足够部署简单合约了。部署 Counter 合约大约需要 0.001-0.01 个测试代币。

### Q: 测试代币有价值吗？
A: 不，测试代币没有真实价值，只用于测试目的。

### Q: 如果水龙头不工作怎么办？
A: 可以在 Monad 社区寻求帮助，或者联系其他开发者分享少量测试代币。

---
**注意**: 请保管好您的私钥密码，不要在任何地方分享您的私钥！
