#!/bin/bash

# 一键部署原生MON代币足球买票系统

echo "🎫 一键部署原生MON代币足球买票系统"
echo "===================================="

# 检查是否有足够余额
WALLET_ADDRESS="0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a"
RPC_URL="https://testnet-rpc.monad.xyz"

BALANCE=$(cast balance $WALLET_ADDRESS --rpc-url $RPC_URL)
if [ "$BALANCE" = "0" ]; then
    echo "❌ 余额不足，请先获取原生MON测试代币"
    echo ""
    echo "📍 获取测试代币地址："
    echo "- https://testnet.monadexplorer.com/"
    echo "- https://www.testnet-monad.xyz/"
    echo ""
    echo "💡 或运行: ./deploy_helper.sh 获取帮助"
    exit 1
fi

BALANCE_ETH=$(cast to-unit $BALANCE ether)
echo "✅ 余额充足: $BALANCE_ETH MON"
echo ""

# 编译合约
echo "🔨 编译合约..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

# 部署 TicketingSystemNative
echo "🎫 部署 TicketingSystemNative..."
TICKETING_ADDRESS=$(forge create src/TicketingSystemNative.sol:TicketingSystemNative \
    --account monad-deployer \
    --rpc-url $RPC_URL \
    --broadcast | grep "Deployed to:" | awk '{print $3}')

if [ -z "$TICKETING_ADDRESS" ]; then
    echo "❌ TicketingSystemNative 部署失败"
    exit 1
fi

echo ""
echo "🎉 部署成功！"
echo "============="
echo "📋 合约地址："
echo "   TicketingSystemNative:  $TICKETING_ADDRESS"
echo "   部署者/管理员:           $WALLET_ADDRESS"
echo "   代币类型:               原生MON代币"
echo ""
echo "💡 下一步："
echo "1. 创建足球赛事"
echo "2. 设置门票类型和价格"
echo "3. 使用原生MON代币购买门票"
echo ""
echo "🔧 快速开始命令："
echo ""
echo "# 1. 创建赛事"
echo "cast send $TICKETING_ADDRESS \"createMatch(string,string,uint256,string)\" \\"
echo "  \"Real Madrid\" \"Barcelona\" $(($(date +%s) + 604800)) \"Santiago Bernabeu\" \\"
echo "  --account monad-deployer --rpc-url $RPC_URL"
echo ""
echo "# 2. 创建VIP门票 (价格: 1 MON = 1000000000000000000 wei)"
echo "cast send $TICKETING_ADDRESS \"createTicketType(uint256,string,uint256,uint256)\" \\"
echo "  1 \"VIP\" 1000000000000000000 50 \\"
echo "  --account monad-deployer --rpc-url $RPC_URL"
echo ""
echo "# 3. 创建普通门票 (价格: 0.5 MON)"
echo "cast send $TICKETING_ADDRESS \"createTicketType(uint256,string,uint256,uint256)\" \\"
echo "  1 \"Regular\" 500000000000000000 100 \\"
echo "  --account monad-deployer --rpc-url $RPC_URL"
echo ""
echo "# 4. 购买VIP门票 (发送1 MON)"
echo "cast send $TICKETING_ADDRESS \"purchaseTicket(uint256)\" 1 \\"
echo "  --value 1000000000000000000 --account monad-deployer --rpc-url $RPC_URL"
echo ""
echo "# 5. 查看我的门票"
echo "cast call $TICKETING_ADDRESS \"getUserTickets(address)\" $WALLET_ADDRESS --rpc-url $RPC_URL"
echo ""
echo "# 6. 查看活跃赛事"
echo "cast call $TICKETING_ADDRESS \"getActiveMatches()\" --rpc-url $RPC_URL"
echo ""
echo "🎮 使用交互脚本 (即将创建):"
echo "./interact_native.sh $TICKETING_ADDRESS"
