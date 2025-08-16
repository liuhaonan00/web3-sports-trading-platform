#!/bin/bash

# 原生MON代币足球买票系统交互脚本
# 提供简单的命令来与部署的原生代币合约交互

RPC_URL="https://testnet-rpc.monad.xyz"
WALLET_ADDRESS="0x61ad1bef3c7c728679c30a26c67bdebcc5d1d43a"

# 检查是否提供了合约地址
if [ -z "$1" ]; then
    echo "使用方法: $0 <TICKETING_SYSTEM_ADDRESS>"
    echo ""
    echo "示例: $0 0x123..."
    exit 1
fi

TICKETING_ADDRESS=$1

echo "🎫 原生MON代币足球买票系统交互工具"
echo "==================================="
echo "TicketingSystemNative: $TICKETING_ADDRESS"
echo "钱包: $WALLET_ADDRESS"
echo "代币类型: 原生MON代币"
echo ""

# 检查当前余额
BALANCE=$(cast balance $WALLET_ADDRESS --rpc-url $RPC_URL)
BALANCE_ETH=$(cast to-unit $BALANCE ether)
echo "当前MON余额: $BALANCE_ETH MON"
echo ""

# 功能菜单
echo "请选择操作："
echo ""
echo "=== 赛事管理 (管理员操作) ==="
echo "1) 创建足球赛事"
echo "2) 创建门票类型"
echo "3) 查看所有赛事"
echo "4) 设置赛事状态"
echo ""
echo "=== 购票操作 ==="
echo "5) 购买门票 (使用原生MON)"
echo "6) 查看我的门票"
echo "7) 退票"
echo ""
echo "=== 查询操作 ==="
echo "8) 查看赛事门票类型"
echo "9) 检查管理员权限"
echo "10) 查看合约余额"
echo "11) 查看门票详情"
echo ""
echo "=== 管理员操作 ==="
echo "12) 提取合约收入"
echo "13) 紧急提取所有资金"

read -p "请选择 (1-13): " choice

case $choice in
    1)
        echo "⚽ 创建足球赛事..."
        read -p "主队名称: " home_team
        read -p "客队名称: " away_team
        read -p "比赛场地: " venue
        
        # 计算一周后的时间戳
        MATCH_TIME=$(($(date +%s) + 604800))
        
        cast send $TICKETING_ADDRESS "createMatch(string,string,uint256,string)" \
            "$home_team" "$away_team" $MATCH_TIME "$venue" \
            --account monad-deployer --rpc-url $RPC_URL
        echo "赛事创建成功！比赛时间: $(date -d @$MATCH_TIME)"
        ;;
    2)
        echo "🎫 创建门票类型..."
        read -p "赛事 ID: " match_id
        read -p "门票类别 (如VIP/Regular/Stand): " category
        read -p "价格 (MON 代币，如 1.5): " price
        read -p "数量: " supply
        
        # 转换价格为 wei (18位小数)
        PRICE_WEI=$(cast to-wei $price ether)
        
        cast send $TICKETING_ADDRESS "createTicketType(uint256,string,uint256,uint256)" \
            $match_id "$category" $PRICE_WEI $supply \
            --account monad-deployer --rpc-url $RPC_URL
        echo "门票类型创建成功！"
        ;;
    3)
        echo "📅 查看所有赛事..."
        cast call $TICKETING_ADDRESS "getActiveMatches()" --rpc-url $RPC_URL
        ;;
    4)
        echo "🔧 设置赛事状态..."
        read -p "赛事 ID: " match_id
        read -p "是否激活 (true/false): " is_active
        
        cast send $TICKETING_ADDRESS "setMatchStatus(uint256,bool)" $match_id $is_active \
            --account monad-deployer --rpc-url $RPC_URL
        echo "赛事状态更新成功！"
        ;;
    5)
        echo "🛒 购买门票..."
        read -p "门票类型 ID: " type_id
        read -p "支付金额 (MON 代币，如 1.5): " amount
        
        # 转换为 wei
        AMOUNT_WEI=$(cast to-wei $amount ether)
        
        cast send $TICKETING_ADDRESS "purchaseTicket(uint256)" $type_id \
            --value $AMOUNT_WEI --account monad-deployer --rpc-url $RPC_URL
        echo "门票购买成功！"
        ;;
    6)
        echo "🎫 查看我的门票..."
        cast call $TICKETING_ADDRESS "getUserTickets(address)" $WALLET_ADDRESS --rpc-url $RPC_URL
        ;;
    7)
        echo "↩️ 退票..."
        read -p "门票 ID: " ticket_id
        cast send $TICKETING_ADDRESS "refundTicket(uint256)" $ticket_id \
            --account monad-deployer --rpc-url $RPC_URL
        echo "退票成功！"
        ;;
    8)
        echo "🎟️ 查看赛事门票类型..."
        read -p "赛事 ID: " match_id
        cast call $TICKETING_ADDRESS "getMatchTicketTypes(uint256)" $match_id --rpc-url $RPC_URL
        ;;
    9)
        echo "👑 检查管理员权限..."
        IS_ADMIN=$(cast call $TICKETING_ADDRESS "isAdmin(address)" $WALLET_ADDRESS --rpc-url $RPC_URL)
        if [ "$IS_ADMIN" = "0x0000000000000000000000000000000000000000000000000000000000000001" ]; then
            echo "✅ 您是管理员"
        else
            echo "❌ 您不是管理员"
        fi
        ;;
    10)
        echo "💼 查看合约余额..."
        BALANCE=$(cast call $TICKETING_ADDRESS "getContractBalance()" --rpc-url $RPC_URL)
        BALANCE_READABLE=$(cast to-unit $BALANCE ether)
        echo "合约 MON 余额: $BALANCE_READABLE MON"
        ;;
    11)
        echo "🔍 查看门票详情..."
        read -p "门票 ID: " ticket_id
        cast call $TICKETING_ADDRESS "tickets(uint256)" $ticket_id --rpc-url $RPC_URL
        ;;
    12)
        echo "💰 提取合约收入..."
        read -p "提取金额 (MON 代币): " amount
        AMOUNT_WEI=$(cast to-wei $amount ether)
        
        cast send $TICKETING_ADDRESS "withdrawMON(uint256)" $AMOUNT_WEI \
            --account monad-deployer --rpc-url $RPC_URL
        echo "提取成功！"
        ;;
    13)
        echo "🚨 紧急提取所有资金..."
        read -p "确定要提取合约中的所有资金吗？(yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            cast send $TICKETING_ADDRESS "emergencyWithdraw()" \
                --account monad-deployer --rpc-url $RPC_URL
            echo "紧急提取完成！"
        else
            echo "操作已取消"
        fi
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "✅ 操作完成！"
echo ""
echo "💡 提示:"
echo "- 重新运行此脚本进行更多操作: $0 $TICKETING_ADDRESS"
echo "- 查看交易状态: https://testnet.monadexplorer.com/"
echo "- 当前余额: $(cast to-unit $(cast balance $WALLET_ADDRESS --rpc-url $RPC_URL) ether) MON"
echo ""
echo "🔧 常用换算："
echo "- 1 MON = 1000000000000000000 wei"
echo "- 0.1 MON = 100000000000000000 wei"
echo "- 0.01 MON = 10000000000000000 wei"
