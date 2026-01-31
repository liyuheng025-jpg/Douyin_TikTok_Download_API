#!/bin/bash

# 抖音/TikTok API Cookie更新脚本
# 用法: ./update_cookie.sh [service] [cookie_file_or_value]

# 默认配置
SERVICE=${1:-"douyin"}
COOKIE_INPUT=${2:-""}
API_URL=${3:-"http://localhost:8001"}

# 检查参数
if [ -z "$COOKIE_INPUT" ]; then
    echo "用法: $0 [service] [cookie_file_or_value] [api_url]"
    echo "  service: 服务名称 (douyin, tiktok, bilibili)，默认为 douyin"
    echo "  cookie_file_or_value: Cookie值 或 包含Cookie的文件路径"
    echo "  api_url: API地址，默认为 http://localhost:8001"
    echo ""
    echo "示例:"
    echo "  $0 douyin \"your_cookie_value\""
    echo "  $0 douyin \"/path/to/cookie_file\" \"http://localhost:8001\""
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

echo "正在更新 $SERVICE 服务的Cookie..."

# 发送API请求更新Cookie
response=$(curl -X POST "$API_URL/api/hybrid/update_cookie" \
  -H "Content-Type: application/json" \
  -d "{\"service\":\"$SERVICE\",\"cookie\":\"$COOKIE\"}" \
  -w "\n%{http_code}" \
  -s)

# 分离响应体和状态码
body=$(echo "$response" | sed '$d')
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
    echo "✅ Cookie更新成功!"
    echo "响应: $body"
else
    echo "❌ Cookie更新失败!"
    echo "HTTP状态码: $status_code"
    echo "响应: $body"
fi