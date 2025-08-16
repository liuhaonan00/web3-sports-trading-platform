#!/bin/bash

# Monad 部署助手脚本
# 这个脚本会帮助您检查余额并部署合约

WALLET_ADDRESS="0xB6dD45e103b2041218EaB0EFF90164992206d001"
RPC_URL="https://testnet-rpc.monad.xyz"

echo "🔍 检查钱包地址: $WALLET_ADDRESS"
echo "🌐 连接到: Monad Testnet"
echo ""

# 检查余额
echo "💰 检查当前余额..."
BALANCE=$(cast balance $WALLET_ADDRESS --rpc-url $RPC_URL)
BALANCE_ETH=$(cast to-unit $BALANCE ether)

echo "余额: $BALANCE wei ($BALANCE_ETH ETH)"
echo ""

# 检查余额是否足够
if [ "$BALANCE" = "0" ]; then
    echo "❌ 余额不足！需要获取测试代币。"
    echo ""
    echo "📝 请按照以下步骤获取测试代币："
    echo "1. 访问 Monad 官方文档或 Discord"
    echo "2. 查找测试网水龙头"
    echo "3. 使用您的地址: $WALLET_ADDRESS"
    echo "4. 获取测试代币后重新运行此脚本"
    exit 1
else
    echo "✅ 余额充足，可以开始部署！"
    echo ""
    
    # 询问是否部署
    echo "🚀 是否现在部署 Counter 合约？(y/n)"
    read -p "请选择: " choice
    
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo "开始部署..."
        forge create src/Counter.sol:Counter --account monad-deployer --broadcast
    else
        echo "取消部署。您可以稍后手动运行："
        echo "forge create src/Counter.sol:Counter --account monad-deployer --broadcast"
    fi
fi
