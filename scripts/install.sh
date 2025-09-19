#!/bin/bash

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装依赖
sudo apt install -y python3 python3-pip python3-venv

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装Python依赖
pip install --upgrade pip
pip install -r requirements.txt

# 复制配置文件
if [ ! -f "config/config.json" ]; then
    cp config/config.example.json config/config.json
    echo "请编辑 config/config.json 配置文件"
fi

# 设置服务
sudo cp scripts/proxy-manager.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable proxy-manager

echo "安装完成，可以使用以下命令启动服务："
echo "sudo systemctl start proxy-manager"
