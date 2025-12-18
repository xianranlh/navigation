#!/bin/bash

# 极光导航 - Debian 12 一键安装部署脚本
# Author: Claude Code
# Date: 2025-12-19
# 适用系统: Debian 12

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目配置
IMAGE_NAME="jg_nav"
CONTAINER_NAME="jg_nav"
PORT="2266"

# MySQL 配置
MYSQL_ROOT_PASSWORD="root123456"  # MySQL root 密码
MYSQL_USER="nav"
MYSQL_PASSWORD="lh116688257"
MYSQL_DATABASE="nav"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户或 sudo 运行此脚本"
        exit 1
    fi
    print_success "Root 权限检查通过"
}

# 检查系统版本
check_system() {
    print_step "检查系统版本..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID

        if [[ "$OS" == *"Debian"* ]]; then
            print_success "检测到 Debian 系统: $OS $VER"

            if [[ "$VER" != "12"* ]]; then
                print_warning "此脚本针对 Debian 12 优化，当前版本为 $VER"
                read -p "是否继续？(y/n): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
        else
            print_error "此脚本仅支持 Debian 系统，当前系统: $OS"
            exit 1
        fi
    else
        print_error "无法检测系统版本"
        exit 1
    fi
}

# 更新系统
update_system() {
    print_step "更新系统软件包..."
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y ca-certificates curl gnupg lsb-release wget apt-transport-https software-properties-common
    print_success "系统更新完成"
}

# 安装 Docker
install_docker() {
    print_step "检查 Docker 安装状态..."

    if command -v docker &> /dev/null; then
        print_info "Docker 已安装: $(docker --version)"
        return
    fi

    print_info "开始安装 Docker..."

    # 删除旧版本
    apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # 添加 Docker 官方 GPG 密钥
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # 添加 Docker 仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 安装 Docker Engine
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动 Docker 服务
    systemctl start docker
    systemctl enable docker

    # 验证安装
    if docker --version &> /dev/null; then
        print_success "Docker 安装成功: $(docker --version)"
    else
        print_error "Docker 安装失败"
        exit 1
    fi
}

# 安装 Docker Compose (独立版本,作为备用)
install_docker_compose() {
    print_step "检查 Docker Compose..."

    # 优先使用 docker compose (插件版本)
    if docker compose version &> /dev/null; then
        print_success "Docker Compose 已安装: $(docker compose version)"
        return
    fi

    # 检查独立版本
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose 已安装: $(docker-compose --version)"
        return
    fi

    print_info "安装 Docker Compose 独立版本..."

    # 获取最新版本
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

    # 下载并安装
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # 创建符号链接
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose 2>/dev/null || true

    print_success "Docker Compose 安装完成"
}

# 安装 MySQL
install_mysql() {
    print_step "检查 MySQL 安装状态..."

    if systemctl is-active --quiet mysql || systemctl is-active --quiet mariadb; then
        print_info "MySQL/MariaDB 服务已运行"
        return
    fi

    if command -v mysql &> /dev/null; then
        print_info "MySQL 客户端已安装"
        # 尝试启动服务
        systemctl start mysql 2>/dev/null || systemctl start mariadb 2>/dev/null || true
        if systemctl is-active --quiet mysql || systemctl is-active --quiet mariadb; then
            print_success "MySQL 服务已启动"
            return
        fi
    fi

    print_info "开始安装 MySQL Server..."

    # 设置非交互式安装
    export DEBIAN_FRONTEND=noninteractive

    # 预设置 MySQL root 密码
    debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"

    # 安装 MySQL
    apt-get install -y mysql-server mysql-client

    # 启动 MySQL 服务
    systemctl start mysql
    systemctl enable mysql

    # 等待 MySQL 启动
    sleep 5

    # 验证安装
    if systemctl is-active --quiet mysql; then
        print_success "MySQL 安装成功: $(mysql --version)"
    else
        print_error "MySQL 服务启动失败"
        exit 1
    fi
}

# 配置 MySQL
configure_mysql() {
    print_step "配置 MySQL 数据库..."

    # 创建 MySQL 配置文件用于免密码登录
    cat > /tmp/mysql_commands.sql <<EOF
-- 创建数据库
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户并授权 (兼容不同 MySQL 版本)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- 授予权限
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- 刷新权限
FLUSH PRIVILEGES;
EOF

    # 执行 SQL 命令
    if mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" < /tmp/mysql_commands.sql 2>/dev/null; then
        print_success "MySQL 配置成功"
    elif mysql -uroot < /tmp/mysql_commands.sql 2>/dev/null; then
        print_success "MySQL 配置成功 (无密码模式)"
    else
        print_warning "使用默认配置可能失败，尝试交互式配置..."
        mysql -uroot < /tmp/mysql_commands.sql
    fi

    # 清理临时文件
    rm -f /tmp/mysql_commands.sql

    # 测试连接
    if mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &> /dev/null; then
        print_success "MySQL 数据库连接测试成功"
    else
        print_error "MySQL 数据库连接失败"
        print_info "数据库: ${MYSQL_DATABASE}"
        print_info "用户: ${MYSQL_USER}"
        print_info "请手动检查 MySQL 配置"
        exit 1
    fi
}

# 安装 Node.js 和 npm
install_nodejs() {
    print_step "检查 Node.js 安装状态..."

    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_info "Node.js 已安装: $NODE_VERSION"

        # 检查版本是否满足要求 (需要 Node.js 16+)
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [ "$MAJOR_VERSION" -ge 16 ]; then
            print_success "Node.js 版本符合要求"
            return
        else
            print_warning "Node.js 版本过低，需要升级"
        fi
    fi

    print_info "安装 Node.js 18.x LTS..."

    # 添加 NodeSource 仓库
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

    # 安装 Node.js
    apt-get install -y nodejs

    # 验证安装
    if node --version &> /dev/null && npm --version &> /dev/null; then
        print_success "Node.js 安装成功: $(node --version)"
        print_success "npm 版本: $(npm --version)"
    else
        print_error "Node.js 安装失败"
        exit 1
    fi
}

# 初始化项目
init_project() {
    print_step "初始化项目..."

    # 检查 package.json
    if [ ! -f "package.json" ]; then
        print_error "未找到 package.json，请确保在项目根目录运行此脚本"
        exit 1
    fi

    # 安装依赖
    print_info "安装项目依赖..."
    npm install

    # 安装数据迁移相关依赖
    print_info "安装数据迁移依赖..."
    npm install --save-dev sqlite3 mysql2 2>/dev/null || true

    print_success "项目初始化完成"
}

# 初始化数据库
init_database() {
    print_step "初始化数据库..."

    # 设置环境变量
    export DATABASE_URL="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"

    # 生成 Prisma Client
    print_info "生成 Prisma Client..."
    npx prisma generate

    # 推送数据库架构
    print_info "推送数据库架构..."
    npx prisma db push --accept-data-loss

    print_success "数据库初始化完成"

    # 检查是否需要迁移 SQLite 数据
    SQLITE_DB="prisma/dev.db"
    if [ -f "$SQLITE_DB" ]; then
        print_info "发现 SQLite 数据库，准备迁移数据..."

        if [ -f "migrate-to-mysql.js" ]; then
            print_info "开始数据迁移..."
            if node migrate-to-mysql.js; then
                print_success "数据迁移成功"
            else
                print_warning "数据迁移失败，将使用空数据库"
            fi
        else
            print_warning "未找到迁移脚本 migrate-to-mysql.js"
        fi
    fi
}

# 停止旧容器
stop_old_container() {
    print_step "清理旧容器..."

    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "停止并删除旧容器..."
        docker compose down -v 2>/dev/null || docker-compose down -v 2>/dev/null || true
        print_success "旧容器已清理"
    fi

    # 清理旧镜像
    if docker images | grep -q "^${IMAGE_NAME}"; then
        print_info "删除旧镜像..."
        docker rmi ${IMAGE_NAME}:latest 2>/dev/null || true
    fi
}

# 构建并启动容器
build_and_start() {
    print_step "构建 Docker 镜像..."
    print_info "这可能需要几分钟，请耐心等待..."

    # 构建镜像
    if docker compose build --no-cache 2>/dev/null || docker-compose build --no-cache; then
        print_success "镜像构建成功"
    else
        print_error "镜像构建失败"
        exit 1
    fi

    # 启动容器
    print_step "启动容器..."
    if docker compose up -d 2>/dev/null || docker-compose up -d; then
        print_success "容器启动成功"
    else
        print_error "容器启动失败"
        exit 1
    fi

    # 等待容器启动
    sleep 5

    # 检查容器状态
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_success "容器运行正常"
    else
        print_error "容器未正常运行"
        print_info "查看容器日志:"
        docker logs ${CONTAINER_NAME} --tail 50
        exit 1
    fi
}

# 配置防火墙
configure_firewall() {
    print_step "配置防火墙..."

    if command -v ufw &> /dev/null; then
        print_info "检测到 UFW 防火墙"
        ufw allow ${PORT}/tcp 2>/dev/null || true
        print_success "已开放端口 ${PORT}"
    elif command -v firewall-cmd &> /dev/null; then
        print_info "检测到 firewalld 防火墙"
        firewall-cmd --permanent --add-port=${PORT}/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        print_success "已开放端口 ${PORT}"
    else
        print_info "未检测到防火墙或防火墙未启用"
    fi
}

# 显示部署信息
show_info() {
    print_separator
    echo -e "${GREEN}✓ 极光导航部署成功！${NC}"
    print_separator

    # 获取服务器 IP
    SERVER_IP=$(hostname -I | awk '{print $1}')

    echo -e "${CYAN}访问信息:${NC}"
    echo -e "  本地访问: ${GREEN}http://localhost:${PORT}${NC}"
    echo -e "  远程访问: ${GREEN}http://${SERVER_IP}:${PORT}${NC}"
    echo ""
    echo -e "${CYAN}容器信息:${NC}"
    echo -e "  容器名称: ${CONTAINER_NAME}"
    echo -e "  镜像名称: ${IMAGE_NAME}:latest"
    echo ""
    echo -e "${CYAN}数据库信息:${NC}"
    echo -e "  数据库: ${MYSQL_DATABASE}"
    echo -e "  用户: ${MYSQL_USER}"
    echo -e "  主机: ${MYSQL_HOST}:${MYSQL_PORT}"
    echo ""
    echo -e "${CYAN}常用命令:${NC}"
    echo -e "  查看日志: ${YELLOW}docker logs -f ${CONTAINER_NAME}${NC}"
    echo -e "  停止服务: ${YELLOW}docker compose down${NC}"
    echo -e "  启动服务: ${YELLOW}docker compose up -d${NC}"
    echo -e "  重启服务: ${YELLOW}docker compose restart${NC}"

    print_separator
}

# 主函数
main() {
    clear
    print_separator
    echo -e "${GREEN}极光导航 - Debian 12 一键安装部署脚本${NC}"
    echo -e "${CYAN}此脚本将自动安装所有依赖并部署应用${NC}"
    print_separator

    # 确认继续
    read -p "是否继续安装？(y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "安装已取消"
        exit 0
    fi

    # 执行安装流程
    check_root
    check_system
    update_system
    install_docker
    install_docker_compose
    install_mysql
    configure_mysql
    install_nodejs
    init_project
    init_database
    stop_old_container
    build_and_start
    configure_firewall
    show_info

    # 询问是否查看日志
    echo ""
    read -p "是否查看容器日志？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker logs -f ${CONTAINER_NAME}
    fi
}

# 错误处理
trap 'print_error "脚本执行出错，请检查上方错误信息"; exit 1' ERR

# 运行主函数
main
