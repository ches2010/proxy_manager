#!/bin/bash

# 检查是否在虚拟环境中
if [ -z "$VIRTUAL_ENV" ]; then
    source venv/bin/activate
fi

# 启动应用
nohup python3 app/main.py > logs/app.log 2>&1 &
echo "Proxy Manager 已启动，进程ID: $!"
