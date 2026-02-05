#!/bin/bash

# 重启Douyin_TikTok_Download_API服务脚本
# 用于在更新Cookie后重新启动服务

echo "🔄 开始重启Douyin_TikTok_Download_API服务..."

# 更全面地终止所有可能的相关进程
# 终止可能存在的Python相关进程
echo "🔍 查找并终止所有相关的Python进程..."
pkill -f "python.*start.py" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "Douyin_TikTok_Download_API" 2>/dev/null
pkill -f "fastapi" 2>/dev/null

# 切换到项目目录
cd /opt/tiger/toutiao/app/Douyin_TikTok_Download_API

# 查找并终止占用8001端口的进程
echo "🔍 查找并终止占用8001端口的进程..."
PORT8001_PIDS=$(lsof -i :8001 2>/dev/null | grep LISTEN | awk '{print $2}' | grep -v PID)

if [ -n "$PORT8001_PIDS" ]; then
    echo "🛑 终止占用8001端口的进程 (PIDs: $PORT8001_PIDS)"
    kill -TERM $PORT8001_PIDS 2>/dev/null
    sleep 3
    # 再次检查并强制终止
    STILL_RUNNING=$(lsof -i :8001 2>/dev/null | grep LISTEN | awk '{print $2}' | grep -v PID)
    if [ -n "$STILL_RUNNING" ]; then
        echo "⚠️  端口8001仍被占用，执行强制终止"
        kill -9 $STILL_RUNNING 2>/dev/null
    fi
else
    echo "ℹ️  未发现占用8001端口的进程"
fi

# 查找并终止可能的start.py进程
echo "🔍 查找并终止可能的start.py进程..."
START_PY_PIDS=$(ps aux | grep start.py | grep -v grep | awk '{print $2}')

if [ -n "$START_PY_PIDS" ]; then
    echo "🛑 终止start.py相关进程 (PIDs: $START_PY_PIDS)"
    kill -TERM $START_PY_PIDS 2>/dev/null
    sleep 2
    # 检查是否还有进程在运行
    for pid in $START_PY_PIDS; do
        if kill -0 $pid 2>/dev/null; then
            echo "⚠️  PID $pid 仍在运行，执行强制终止"
            kill -9 $pid 2>/dev/null
        fi
    done
    sleep 1
else
    echo "ℹ️  未发现start.py相关进程"
fi

# 检查是否有其他可能的API服务端口被占用
echo "🔍 检查其他可能的API服务端口..."
for port in {8000..8010}; do
    if [ $port -ne 8001 ]; then
        OTHER_PORT_PIDS=$(lsof -i :$port 2>/dev/null | grep LISTEN | awk '{print $2}' | grep -v PID)
        if [ -n "$OTHER_PORT_PIDS" ]; then
            # 检查这些进程是否与我们的应用相关
            for pid in $OTHER_PORT_PIDS; do
                if ps -p $pid -o args= 2>/dev/null | grep -q -E "(uvicorn|fastapi|python.*start|Douyin_TikTok_Download)"; then
                    echo "🛑 发现相关API服务运行在端口 $port (PID: $pid)，正在终止..."
                    kill -TERM $pid 2>/dev/null
                    sleep 1
                    # 如果进程仍在运行，则强制终止
                    if kill -0 $pid 2>/dev/null; then
                        kill -9 $pid 2>/dev/null
                    fi
                fi
            done
        fi
    fi
done

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

# 检查依赖
echo "📦 检查依赖包..."
if [ -f "requirements.txt" ]; then
    echo "✅ 发现requirements.txt，跳过依赖安装（假设已安装）"
else
    echo "⚠️  未找到requirements.txt文件"
fi

# 检查start.py文件
if [ ! -f "start.py" ]; then
    echo "❌ 未找到start.py文件，请在项目根目录下运行此脚本"
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
