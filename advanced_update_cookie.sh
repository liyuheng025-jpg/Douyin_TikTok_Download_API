#!/bin/bash

# 高级抖音Cookie更新脚本
# 支持同时更新配置文件和运行中的服务
# 用法: ./advanced_update_cookie.sh [cookie_value_or_file]

COOKIE_INPUT=${1:-""}
CONFIG_FILE="./crawlers/douyin/web/douyin_cookies.yaml"
API_URL="http://localhost:8001"

# 检查参数
if [ -z "$COOKIE_INPUT" ]; then
    echo "用法: $0 [cookie_value_or_file]"
    echo "  cookie_value_or_file: Cookie值 或 包含Cookie的文件路径"
    echo ""
    echo "示例:"
    echo "  $0 \"your_cookie_value\""
    echo "  $0 \"/path/to/cookie_file\""
    exit 1
fi

# 判断输入是文件还是直接的Cookie值
if [ -f "$COOKIE_INPUT" ]; then
    echo "从文件读取Cookie: $COOKIE_INPUT"
    COOKIE=$(cat "$COOKIE_INPUT")
else
    COOKIE="$COOKIE_INPUT"
fi

# 检查是否成功获取到Cookie
if [ -z "$COOKIE" ]; then
    echo "错误: 未能获取到有效的Cookie值"
    exit 1
fi

echo "==================================="
echo "开始更新抖音Cookie..."
echo "==================================="

# 1. 首先尝试通过API更新Cookie（如果服务正在运行）
echo "1. 尝试通过API更新运行中的服务..."
API_RESPONSE=$(curl -X POST "$API_URL/api/hybrid/update_cookie" \
  -H "Content-Type: application/json" \
  -d "{\"service\":\"douyin\",\"cookie\":\"$COOKIE\"}" \
  -w "\n%{http_code}" \
  -s 2>/dev/null)

if [ $? -eq 0 ]; then
    API_BODY=$(echo "$API_RESPONSE" | sed '$d')
    API_STATUS_CODE=$(echo "$API_RESPONSE" | tail -n1)
    
    if [ "$API_STATUS_CODE" -eq 200 ]; then
        echo "✅ API更新成功!"
        echo "响应: $API_BODY"
    else
        echo "⚠️  API更新失败 (状态码: $API_STATUS_CODE)"
        echo "响应: $API_BODY"
        echo "继续更新配置文件..."
    fi
else
    echo "⚠️  无法连接到API服务，将仅更新配置文件"
    echo "请确保服务正在运行或稍后重启服务以应用更改"
fi

echo ""

# 2. 更新配置文件
echo "2. 更新配置文件..."
CONFIG_BACKUP="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# 备份原配置文件
cp "$CONFIG_FILE" "$CONFIG_BACKUP"
if [ $? -ne 0 ]; then
    echo "❌ 无法备份配置文件: $CONFIG_FILE"
    exit 1
fi

# 更新配置文件中的Cookie值
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed语法
    sed -i '' "s|Cookie: \".*\"|Cookie: \"$COOKIE\"|" "$CONFIG_FILE"
else
    # Linux sed语法
    sed -i "s|Cookie: \".*\"|Cookie: \"$COOKIE\"|" "$CONFIG_FILE"
fi

if [ $? -eq 0 ]; then
    echo "✅ 配置文件更新成功!"
    echo "配置文件: $CONFIG_FILE"
    echo "备份文件: $CONFIG_BACKUP"
else
    echo "❌ 配置文件更新失败!"
    echo "正在恢复备份..."
    cp "$CONFIG_BACKUP" "$CONFIG_FILE"
    echo "已恢复备份: $CONFIG_BACKUP"
    exit 1
fi

echo ""
echo "==================================="
echo "Cookie更新完成!"
echo "==================================="
echo "注意事项:"
echo "- 如果API服务正在运行，已通过API更新了Cookie"
echo "- 已更新配置文件，下次启动时将使用新Cookie"
echo "- 如果API服务未运行，请重启服务以应用配置文件中的更改"