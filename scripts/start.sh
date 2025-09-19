#!/bin/bash

# 定义日志目录
LOG_DIR="$(dirname "$0")/../logs"

# 检查并创建日志目录（如果不存在）
if [ ! -d "$LOG_DIR" ]; then
    echo "创建日志目录: $LOG_DIR"
    mkdir -p "$LOG_DIR"
fi

# 检查是否在虚拟环境中
if [ -z "$VIRTUAL_ENV" ]; then
    echo "激活虚拟环境..."
    source "$(dirname "$0")/../venv/bin/activate"
fi

# 启动应用
echo "启动 Proxy Manager..."
nohup python3 "$(dirname "$0")/../app/main.py" > "$LOG_DIR/app.log" 2>&1 &
echo "Proxy Manager 已启动，进程ID: $!"
echo "日志文件: $LOG_DIR/app.log"
