#!/bin/bash
set -e

# 定义颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 定义变量
APP_NAME="proxy_manager"
APP_DIR="/opt/$APP_NAME"
GIT_REPO="https://github.com/yourusername/proxy_manager.git"  # 替换为你的GitHub仓库地址
VENV_DIR="$APP_DIR/venv"
CONFIG_DIR="$APP_DIR/config"
LOG_DIR="$APP_DIR/logs"
SERVICE_NAME="proxy-manager"

# 显示欢迎信息
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}         欢迎使用 Proxy Manager 一键安装脚本         ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误: 请使用root权限运行此脚本 (sudo ./install_proxy_manager.sh)${NC}"
    exit 1
fi

# 检查系统是否为Ubuntu
if [ ! -f /etc/lsb-release ]; then
    echo -e "${RED}错误: 此脚本仅支持Ubuntu系统${NC}"
    exit 1
fi

# 安装依赖
echo -e "${YELLOW}1. 正在安装系统依赖...${NC}"
apt update -y > /dev/null
apt install -y python3 python3-pip python3-venv git curl wget > /dev/null
echo -e "${GREEN}系统依赖安装完成${NC}"

# 检查并克隆仓库
echo -e "${YELLOW}2. 正在获取Proxy Manager代码...${NC}"
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}检测到已有安装，将进行更新...${NC}"
    cd "$APP_DIR"
    git pull origin main > /dev/null
else
    git clone "$GIT_REPO" "$APP_DIR" > /dev/null
    cd "$APP_DIR"
fi
echo -e "${GREEN}代码获取完成${NC}"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 设置Python虚拟环境
echo -e "${YELLOW}3. 正在配置Python环境...${NC}"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR" > /dev/null
fi
source "$VENV_DIR/bin/activate"
pip install --upgrade pip > /dev/null
pip install -r requirements.txt > /dev/null
deactivate
echo -e "${GREEN}Python环境配置完成${NC}"

# 配置文件处理
echo -e "${YELLOW}4. 正在配置应用...${NC}"
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    cp "$CONFIG_DIR/config.example.json" "$CONFIG_DIR/config.json"
    
    # 自动配置一些参数
    SERVER_IP=$(curl -s http://icanhazip.com || curl -s http://ifconfig.me)
    sed -i "s/\"host\": \"0.0.0.0\"/\"host\": \"$SERVER_IP\"/g" "$CONFIG_DIR/config.json"
    
    # 生成随机密码
    RANDOM_PASS=$(openssl rand -hex 8)
    sed -i "s/\"password\": \"password\"/\"password\": \"$RANDOM_PASS\"/g" "$CONFIG_DIR/config.json"
    echo -e "${YELLOW}已生成随机管理密码: $RANDOM_PASS${NC}"
    echo -e "${YELLOW}请妥善保存，后续可在配置文件中修改${NC}"
fi
echo -e "${GREEN}应用配置完成${NC}"

# 设置系统服务
echo -e "${YELLOW}5. 正在配置系统服务...${NC}"
cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=Proxy Manager Service
After=network.target

[Service]
User=root
WorkingDirectory=$APP_DIR
ExecStart=$VENV_DIR/bin/python app/main.py
Restart=always
RestartSec=5
StandardOutput=append:$LOG_DIR/service.log
StandardError=append:$LOG_DIR/error.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME" > /dev/null
systemctl restart "$SERVICE_NAME"
echo -e "${GREEN}系统服务配置完成${NC}"

# 检查服务状态
echo -e "${YELLOW}6. 正在检查服务状态...${NC}"
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "${GREEN}服务启动成功${NC}"
else
    echo -e "${RED}服务启动失败，请查看日志: $LOG_DIR/error.log${NC}"
    exit 1
fi

# 显示访问信息
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}         安装完成！         ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "${YELLOW}管理界面地址: http://$SERVER_IP:5000${NC}"
echo -e "${YELLOW}管理员用户名: admin${NC}"
echo -e "${YELLOW}管理员密码: $RANDOM_PASS${NC}"
echo ""
echo -e "${YELLOW}常用命令:${NC}"
echo -e "  启动服务: sudo systemctl start $SERVICE_NAME"
echo -e "  停止服务: sudo systemctl stop $SERVICE_NAME"
echo -e "  重启服务: sudo systemctl restart $SERVICE_NAME"
echo -e "  查看状态: sudo systemctl status $SERVICE_NAME"
echo -e "  查看日志: tail -f $LOG_DIR/app.log"
echo ""
echo -e "${GREEN}感谢使用Proxy Manager！${NC}"
