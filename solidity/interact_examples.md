# 智能合约交互示例

## 假设您的合约地址是: CONTRACT_ADDRESS

### 1. 读取操作（cast call）- 免费

```bash
# 读取当前 number 值
cast call CONTRACT_ADDRESS "number()" --rpc-url https://testnet-rpc.monad.xyz

# 结果示例: 0x0000000000000000000000000000000000000000000000000000000000000000 (表示 0)
```

### 2. 写入操作（cast send）- 需要 gas 费

```bash
# 设置 number 为 42
cast send CONTRACT_ADDRESS "setNumber(uint256)" 42 \
  --account monad-deployer \
  --rpc-url https://testnet-rpc.monad.xyz

# 增加计数
cast send CONTRACT_ADDRESS "increment()" \
  --account monad-deployer \
  --rpc-url https://testnet-rpc.monad.xyz
```

### 3. 完整的交互流程

```bash
# 1. 读取初始值
echo "初始值:"
cast call CONTRACT_ADDRESS "number()" --rpc-url https://testnet-rpc.monad.xyz

# 2. 设置为 100
echo "设置为 100..."
cast send CONTRACT_ADDRESS "setNumber(uint256)" 100 \
  --account monad-deployer \
  --rpc-url https://testnet-rpc.monad.xyz

# 3. 读取新值
echo "新值:"
cast call CONTRACT_ADDRESS "number()" --rpc-url https://testnet-rpc.monad.xyz

# 4. 增加 1
echo "增加 1..."
cast send CONTRACT_ADDRESS "increment()" \
  --account monad-deployer \
  --rpc-url https://testnet-rpc.monad.xyz

# 5. 读取最终值
echo "最终值:"
cast call CONTRACT_ADDRESS "number()" --rpc-url https://testnet-rpc.monad.xyz
```

## 权限测试

### 原始 Counter 合约
- ✅ 任何人都可以调用 `setNumber()`
- ✅ 任何人都可以调用 `increment()`
- ✅ 任何人都可以读取 `number`

### 带权限的 CounterWithPermissions 合约
- 🔒 只有 owner 可以调用 `setNumber()`
- ✅ 任何人都可以调用 `increment()`
- 🔒 只有 owner 可以调用 `reset()`
- ✅ 任何人都可以读取 `number`

## 实际安全考虑

### 原始合约的风险
1. **恶意重置**: 攻击者可以将计数器重置为任意值
2. **竞争条件**: 多个用户同时修改可能导致意外结果
3. **垃圾数据**: 任何人都可以设置无意义的数值

### 改进建议
1. **添加访问控制**: 使用 `onlyOwner` 等修饰符
2. **使用 OpenZeppelin**: 利用成熟的权限管理库
3. **添加事件日志**: 记录重要操作
4. **数值验证**: 添加合理性检查

```solidity
// 示例：添加事件和验证
event NumberChanged(uint256 oldNumber, uint256 newNumber, address changedBy);

function setNumber(uint256 newNumber) public onlyOwner {
    require(newNumber <= 1000000, "Number too large");
    uint256 oldNumber = number;
    number = newNumber;
    emit NumberChanged(oldNumber, newNumber, msg.sender);
}
```
