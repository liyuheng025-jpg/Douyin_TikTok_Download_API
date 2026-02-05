#!/bin/bash

# 重启Douyin_TikTok_Download_API服务脚本
# 用于在更新Cookie后重新启动服务

echo "🔄 开始重启Douyin_TikTok_Download_API服务..."

# 查找并终止现有的服务进程
echo "🔍 查找现有服务进程..."
EXISTING_PIDS=$(lsof -i :8001 2>/dev/null | grep LISTEN | awk '{print $2}' | grep -v PID)

if [ -n "$EXISTING_PIDS" ]; then
    echo "🛑 终止现有服务进程 (PID: $EXISTING_PIDS)"
    kill -TERM $EXISTING_PIDS 2>/dev/null
    # 等待优雅关闭，如果进程未退出，则强制终止
    sleep 3
    STILL_RUNNING=$(lsof -i :8001 2>/dev/null | grep LISTEN | awk '{print $2}' | grep -v PID)
    if [ -n "$STILL_RUNNING" ]; then
        echo "⚠️  服务未优雅关闭，执行强制终止"
        kill -9 $STILL_RUNNING 2>/dev/null
    fi
else
    echo "ℹ️  未发现运行中的服务进程"
fi

# 等待端口释放
echo "⏳ 等待端口8001释放..."
MAX_WAIT=30
WAIT_COUNT=0
while lsof -i :8001 >/dev/null 2>&1; do
    sleep 1
    ((WAIT_COUNT++))
    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo "⚠️  等待超时，继续启动服务"
        break
    fi
done

echo "✅ 端口8001已释放"

# 检查Python环境
if [ -f "venv310/bin/python3" ]; then
    echo "🔋 使用Python 3.10虚拟环境"
    PYTHON_CMD="venv310/bin/python3"
elif [ -f "venv/bin/python" ]; then
    echo "🔋 使用虚拟环境"
    PYTHON_CMD="venv/bin/python"
elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    echo "✅ 发现Python3命令"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    echo "✅ 发现Python命令"
else
    echo "❌ 未找到Python命令，请确保已安装Python"
    exit 1
fi


# 启动服务
echo "🚀 启动Douyin_TikTok_Download_API服务..."
nohup $PYTHON_CMD /opt/tiger/toutiao/app/Douyin_TikTok_Download_API/start.py > service.log 2>&1 &
SERVICE_PID=$!

if [ $? -eq 0 ]; then
    echo "✅ 服务启动成功！"
    echo "📊 进程ID: $SERVICE_PID"
    echo "🌐 访问地址: http://localhost:8001"
    echo "📖 API文档: http://localhost:8001/docs"
    echo "📝 日志文件: service.log"
    
    # 等待几秒让服务启动
    sleep 5
    
    # 检查服务是否真的在运行
    if lsof -i :8001 >/dev/null 2>&1; then
        echo "✅ 服务正在端口8001上运行"
        echo "🎉 重启完成！"
    else
        echo "❌ 服务可能未能正常启动，请检查service.log获取更多信息"
        echo "💡 提示: 您可以运行 'tail -f service.log' 来查看实时日志"
        exit 1
    fi
else
    echo "❌ 服务启动失败"
    exit 1
fi

echo ""
echo "📋 使用说明:"
echo "   - 服务将在后台运行"
echo "   - 可通过 'curl http://localhost:8001/docs' 验证服务状态"
echo "   - 可通过 'tail -f service.log' 查看实时日志"
echo "   - 要停止服务，可以运行: 'pkill -f start.py'"
