# Proxy Manager

一个功能强大的代理管理工具，支持自动获取、验证、筛选和转发代理。

## 功能特点

- 自动从多个来源获取代理
- 支持HTTP和SOCKS5代理协议
- 代理质量验证和自动筛选
- 基于Web的管理界面
- 支持代理轮换和按地区筛选
- 可作为本地代理服务器转发请求

## 安装指南

### 快速安装

```bash
# 克隆仓库
git clone https://github.com/yourusername/proxy_manager.git
cd proxy_manager

# 运行安装脚本
chmod +x scripts/install.sh
./scripts/install.sh
```

# 运行安装脚本
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

### 手动安装

1. 安装依赖包
```bash
sudo apt install -y python3 python3-pip python3-venv
```

2. 创建并激活虚拟环境
```bash
python3 -m venv venv
source venv/bin/activate
```

3. 安装Python依赖
```bash
pip install -r requirements.txt
```

4. 配置文件
```bash
cp config/config.example.json config/config.json
# 编辑配置文件
nano config/config.json
```

## 使用方法

### 启动服务

```bash
# 使用systemd（推荐）
sudo systemctl start proxy-manager

# 或直接运行
./scripts/start.sh
```

### 访问管理界面

打开浏览器，访问 `http://服务器IP:5000`

## 配置说明

配置文件位于 `config/config.json`，主要配置项：

- `general`: 通用设置，包括验证线程数、失败阈值等
- `server`: 代理服务设置，包括HTTP和SOCKS5端口
- `web_ui`: Web界面设置
- `auto_fetch`: 自动获取代理设置

## 停止服务

```bash
# 使用systemd
sudo systemctl stop proxy-manager

# 或使用脚本
./scripts/stop.sh
```
