#!/bin/bash

# 原生MON代币版本足球买票系统部署助手脚本
# 这个脚本会帮助您检查余额并部署使用原生MON代币的TicketingSystem合约

WALLET_ADDRESS="0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a"
RPC_URL="https://testnet-rpc.monad.xyz"

echo "🎫 原生MON代币足球买票系统部署助手"
echo "======================================="
echo "🔍 检查钱包地址: $WALLET_ADDRESS"
echo "🌐 连接到: Monad Testnet"
echo "💰 使用原生MON代币 (不需要ERC-20代币合约)"
echo ""

# 检查余额
echo "💰 检查当前原生MON余额..."
BALANCE=$(cast balance $WALLET_ADDRESS --rpc-url $RPC_URL)
BALANCE_ETH=$(cast to-unit $BALANCE ether)

echo "余额: $BALANCE wei ($BALANCE_ETH MON)"
echo ""

# 检查余额是否足够
if [ "$BALANCE" = "0" ]; then
    echo "❌ 余额不足！需要获取测试代币。"
    echo ""
    echo "📝 请按照以下步骤获取原生MON测试代币："
    echo "1. 访问 https://testnet.monadexplorer.com/"
    echo "2. 或访问 https://www.testnet-monad.xyz/"
    echo "3. 连接钱包并领取测试代币"
    echo "4. 使用您的地址: $WALLET_ADDRESS"
    echo "5. 获取测试代币后重新运行此脚本"
    exit 1
fi

echo "✅ 余额充足，可以开始部署！"
echo ""

# 选择部署选项
echo "请选择部署选项："
echo "1) 直接部署 TicketingSystemNative 合约"
echo "2) 查看部署状态"
echo "3) 估算 gas 费用"
read -p "请选择 (1-3): " choice

case $choice in
    1)
        echo ""
        echo "🎫 部署 TicketingSystemNative 合约..."
        echo "正在编译..."
        forge build
        
        if [ $? -ne 0 ]; then
            echo "❌ 编译失败，请检查代码"
            exit 1
        fi
        
        echo "开始部署..."
        DEPLOY_RESULT=$(forge create src/TicketingSystemNative.sol:TicketingSystemNative \
            --account monad-deployer \
            --rpc-url $RPC_URL \
            --broadcast)
        
        # 提取合约地址
        CONTRACT_ADDRESS=$(echo "$DEPLOY_RESULT" | grep "Deployed to:" | awk '{print $3}')
        
        if [ -n "$CONTRACT_ADDRESS" ]; then
            echo ""
            echo "🎉 部署成功！"
            echo "============="
            echo "📋 合约信息："
            echo "   TicketingSystemNative: $CONTRACT_ADDRESS"
            echo "   部署者/管理员:          $WALLET_ADDRESS"
            echo "   代币类型:              原生MON代币"
            echo ""
            echo "💡 下一步："
            echo "1. 创建足球赛事"
            echo "2. 设置门票类型和价格"
            echo "3. 使用原生MON代币购买门票"
            echo ""
            echo "🔧 快速测试命令："
            echo "# 创建赛事 (需要管理员权限)"
            echo "cast send $CONTRACT_ADDRESS \"createMatch(string,string,uint256,string)\" \"Real Madrid\" \"Barcelona\" $(($(date +%s) + 604800)) \"Santiago Bernabeu\" --account monad-deployer --rpc-url $RPC_URL"
            echo ""
            echo "# 创建VIP门票类型 (价格: 1 MON)"
            echo "cast send $CONTRACT_ADDRESS \"createTicketType(uint256,string,uint256,uint256)\" 1 \"VIP\" 1000000000000000000 50 --account monad-deployer --rpc-url $RPC_URL"
            echo ""
            echo "# 购买门票 (发送1 MON)"
            echo "cast send $CONTRACT_ADDRESS \"purchaseTicket(uint256)\" 1 --value 1000000000000000000 --account monad-deployer --rpc-url $RPC_URL"
        else
            echo "❌ 部署失败，请检查日志"
            exit 1
        fi
        ;;
    2)
        echo ""
        echo "📊 检查部署状态..."
        echo "钱包地址: $WALLET_ADDRESS"
        echo "当前余额: $BALANCE_ETH MON"
        echo ""
        echo "💡 使用以下命令检查合约："
        echo "cast code <合约地址> --rpc-url $RPC_URL"
        ;;
    3)
        echo ""
        echo "📊 估算 gas 费用..."
        forge build > /dev/null 2>&1
        
        # 获取合约字节码大小
        BYTECODE_SIZE=$(cat out/TicketingSystemNative.sol/TicketingSystemNative.json | jq -r '.bytecode.object' | wc -c)
        BYTECODE_SIZE=$((BYTECODE_SIZE / 2 - 1)) # 转换为字节数
        
        echo "合约字节码大小: $BYTECODE_SIZE bytes"
        echo "预估部署 gas: ~2,000,000"
        echo "预估部署费用: ~0.1 MON (在当前 gas 价格下)"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "🔧 有用的命令："
echo "- 检查合约代码: cast code <地址> --rpc-url $RPC_URL"
echo "- 查看合约余额: cast call <地址> \"getContractBalance()\" --rpc-url $RPC_URL"
echo "- 调用只读函数: cast call <地址> <函数签名> [参数] --rpc-url $RPC_URL"
echo "- 发送交易: cast send <地址> <函数签名> [参数] --value <MON数量> --account monad-deployer --rpc-url $RPC_URL"
echo ""
echo "📚 查看完整使用指南: cat TICKETING_SYSTEM_GUIDE.md"
