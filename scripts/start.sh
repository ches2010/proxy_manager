#!/bin/bash

# 定义基础路径
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$BASE_DIR/logs"
CONFIG_FILE="$BASE_DIR/config/config.json"
VENV_DIR="$BASE_DIR/venv"

# 检查并创建日志目录
if [ ! -d "$LOG_DIR" ]; then
    echo "创建日志目录: $LOG_DIR"
    mkdir -p "$LOG_DIR"
fi

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件不存在，使用默认配置..."
    # 如果没有配置文件，使用默认值
    WEB_HOST="0.0.0.0"
    WEB_PORT=5000
else
    # 从配置文件中读取Web服务配置（需要jq工具）
    if command -v jq &> /dev/null; then
        WEB_HOST=$(jq -r '.web_ui.host' "$CONFIG_FILE")
        WEB_PORT=$(jq -r '.web_ui.port' "$CONFIG_FILE")
        # 处理可能的空值
        WEB_HOST=${WEB_HOST:-"0.0.0.0"}
        WEB_PORT=${WEB_PORT:-5000}
    else
        echo "警告: 未安装jq工具，无法解析配置文件，使用默认端口"
        WEB_HOST="0.0.0.0"
        WEB_PORT=5000
    fi
fi

# 获取服务器IP地址
# 尝试多种方式获取公网IP
SERVER_IP=$(curl -s http://icanhazip.com || curl -s http://ifconfig.me || hostname -I | awk '{print $1}')

# 检查并激活虚拟环境
if [ -z "$VIRTUAL_ENV" ] && [ -d "$VENV_DIR" ]; then
    echo "激活虚拟环境..."
    source "$VENV_DIR/bin/activate"
fi

# 启动应用
echo "启动 Proxy Manager..."
nohup python3 "$BASE_DIR/app/main.py" > "$LOG_DIR/app.log" 2>&1 &
PID=$!
echo "Proxy Manager 已启动，进程ID: $PID"
echo "日志文件: $LOG_DIR/app.log"

# 显示Web访问地址
echo ""
echo "=========================================="
echo "Web 管理界面访问地址:"

# 如果配置为0.0.0.0，则显示服务器IP
if [ "$WEB_HOST" = "0.0.0.0" ] || [ "$WEB_HOST" = "localhost" ]; then
    echo "  http://$SERVER_IP:$WEB_PORT"
else
    echo "  http://$WEB_HOST:$WEB_PORT"
fi
echo "=========================================="
