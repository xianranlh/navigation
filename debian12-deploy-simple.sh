#!/bin/bash

# 极光导航 - Debian 12 简化部署脚本
# 适用于已有 Docker、Docker Compose、MySQL 容器的环境
# Author: Claude Code
# Date: 2025-12-19

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
PORT="13000"  # 修改为 13000 端口

# MySQL 配置 (容器版本)
MYSQL_CONTAINER_NAME="mysql"  # MySQL 容器名称,根据实际情况修改
MYSQL_USER="nav"
MYSQL_PASSWORD="lh116688257"
MYSQL_DATABASE="nav"
MYSQL_HOST="host.docker.internal"  # Docker 容器访问宿主机的 MySQL
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

# 检查 Docker 环境
check_docker() {
    print_step "检查 Docker 环境..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker 未运行,请先启动 Docker"
        exit 1
    fi

    print_success "Docker 环境正常: $(docker --version)"
}

# 检查 Docker Compose
check_docker_compose() {
    print_step "检查 Docker Compose..."

    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装"
        exit 1
    fi

    if docker compose version &> /dev/null; then
        print_success "Docker Compose 正常: $(docker compose version --short)"
    else
        print_success "Docker Compose 正常: $(docker-compose --version)"
    fi
}

# 检查 MySQL 容器
check_mysql_container() {
    print_step "检查 MySQL 容器..."

    # 尝试多个常见的 MySQL 容器名称
    POSSIBLE_NAMES=("mysql" "mysql-container" "mysql-server" "db" "mariadb")
    MYSQL_FOUND=false

    for name in "${POSSIBLE_NAMES[@]}"; do
        if docker ps --format '{{.Names}}' | grep -q "^${name}$"; then
            MYSQL_CONTAINER_NAME="$name"
            MYSQL_FOUND=true
            print_success "找到 MySQL 容器: $name"
            break
        fi
    done

    if [ "$MYSQL_FOUND" = false ]; then
        print_warning "未找到运行中的 MySQL 容器"
        print_info "当前运行的容器列表:"
        docker ps --format "  - {{.Names}}"
        echo ""
        read -p "请输入 MySQL 容器名称 (直接回车跳过检查): " input_name
        if [ -n "$input_name" ]; then
            MYSQL_CONTAINER_NAME="$input_name"
        else
            print_warning "跳过 MySQL 容器检查"
            return
        fi
    fi

    # 检查容器状态
    if docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER_NAME}$"; then
        print_success "MySQL 容器运行正常"
    else
        print_error "MySQL 容器未运行"
        exit 1
    fi
}

# 测试 MySQL 连接
test_mysql_connection() {
    print_step "测试 MySQL 连接..."

    # 尝试从容器内连接 MySQL
    if docker exec ${MYSQL_CONTAINER_NAME} mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &> /dev/null; then
        print_success "MySQL 连接测试成功"
    else
        print_warning "无法直接连接到 MySQL"
        print_info "这可能是正常的,应用容器将通过 ${MYSQL_HOST} 连接"
    fi

    # 检查数据库是否存在
    if docker exec ${MYSQL_CONTAINER_NAME} mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${MYSQL_DATABASE}'" \
        -s -N 2>/dev/null | grep -q "${MYSQL_DATABASE}"; then
        print_success "数据库 '${MYSQL_DATABASE}' 已存在"
    else
        print_info "数据库 '${MYSQL_DATABASE}' 不存在,将在初始化时创建"
    fi
}

# 检查 Node.js
check_nodejs() {
    print_step "检查 Node.js 环境..."

    if ! command -v node &> /dev/null; then
        print_error "Node.js 未安装,请先安装 Node.js 16 或更高版本"
        exit 1
    fi

    NODE_VERSION=$(node --version)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')

    if [ "$MAJOR_VERSION" -lt 16 ]; then
        print_error "Node.js 版本过低 ($NODE_VERSION),需要 16 或更高版本"
        exit 1
    fi

    print_success "Node.js 环境正常: $NODE_VERSION"
}

# 安装项目依赖
install_dependencies() {
    print_step "安装项目依赖..."

    if [ ! -f "package.json" ]; then
        print_error "未找到 package.json,请确保在项目根目录运行此脚本"
        exit 1
    fi

    # 检查是否需要安装依赖
    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
        print_info "安装 npm 依赖..."
        npm install
        print_success "依赖安装完成"
    else
        print_info "依赖已是最新,跳过安装"
    fi

    # 安装数据迁移依赖 (如果需要)
    if [ -f "migrate-to-mysql.js" ]; then
        print_info "检查数据迁移依赖..."
        npm install --save-dev sqlite3 mysql2 2>/dev/null || true
    fi
}

# 初始化数据库
init_database() {
    print_step "初始化数据库..."

    # 确保数据库存在
    print_info "检查并创建数据库..."
    docker exec ${MYSQL_CONTAINER_NAME} mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || \
    docker exec ${MYSQL_CONTAINER_NAME} mysql -uroot -p"${MYSQL_PASSWORD}" \
        -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true

    # 设置环境变量
    export DATABASE_URL="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"

    # 生成 Prisma Client
    print_info "生成 Prisma Client..."
    npx prisma generate

    # 推送数据库架构
    print_info "推送数据库架构..."
    npx prisma db push --accept-data-loss

    print_success "数据库初始化完成"
}

# 迁移 SQLite 数据
migrate_sqlite_data() {
    print_step "检查是否需要数据迁移..."

    SQLITE_DB="prisma/dev.db"

    if [ ! -f "$SQLITE_DB" ]; then
        print_info "未找到 SQLite 数据库,跳过迁移"
        return
    fi

    # 检查 MySQL 数据库是否为空
    TABLE_COUNT=$(docker exec ${MYSQL_CONTAINER_NAME} mysql -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -D"${MYSQL_DATABASE}" -e "SHOW TABLES" -s -N 2>/dev/null | wc -l || echo "0")

    if [ "$TABLE_COUNT" -gt 0 ]; then
        print_info "数据库已有数据 ($TABLE_COUNT 个表),跳过迁移"
        return
    fi

    if [ ! -f "migrate-to-mysql.js" ]; then
        print_warning "未找到迁移脚本,跳过数据迁移"
        return
    fi

    print_info "开始迁移 SQLite 数据到 MySQL..."
    if node migrate-to-mysql.js; then
        print_success "数据迁移成功"
    else
        print_warning "数据迁移失败,将使用空数据库"
    fi
}

# 停止旧容器
stop_old_container() {
    print_step "清理旧容器..."

    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "停止并删除旧容器..."
        docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
        sleep 2
        print_success "旧容器已清理"
    else
        print_info "未发现旧容器"
    fi

    # 可选: 清理旧镜像
    if docker images | grep -q "^${IMAGE_NAME}"; then
        read -p "是否删除旧镜像? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker rmi ${IMAGE_NAME}:latest 2>/dev/null || true
            print_success "旧镜像已删除"
        fi
    fi
}

# 构建 Docker 镜像
build_image() {
    print_step "构建 Docker 镜像..."
    print_info "这可能需要几分钟,请耐心等待..."

    if docker compose build --no-cache 2>/dev/null || docker-compose build --no-cache; then
        print_success "镜像构建成功"
    else
        print_error "镜像构建失败"
        exit 1
    fi
}

# 启动容器
start_container() {
    print_step "启动容器..."

    if docker compose up -d 2>/dev/null || docker-compose up -d; then
        print_success "容器启动成功"
    else
        print_error "容器启动失败"
        exit 1
    fi

    # 等待容器启动
    print_info "等待容器启动..."
    sleep 5
}

# 检查容器状态
check_container_status() {
    print_step "检查容器状态..."

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_success "容器运行正常"

        # 检查应用健康状态
        print_info "检查应用健康状态..."
        sleep 3

        if curl -s http://localhost:${PORT} > /dev/null 2>&1; then
            print_success "应用响应正常"
        else
            print_warning "应用可能还在启动中,请稍后访问"
        fi
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

    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        print_info "配置 UFW 防火墙..."
        ufw allow ${PORT}/tcp 2>/dev/null || true
        print_success "已开放端口 ${PORT}"
    elif command -v firewall-cmd &> /dev/null && firewall-cmd --state &> /dev/null; then
        print_info "配置 firewalld 防火墙..."
        firewall-cmd --permanent --add-port=${PORT}/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        print_success "已开放端口 ${PORT}"
    else
        print_info "未检测到活动的防火墙,跳过配置"
    fi
}

# 显示部署信息
show_deployment_info() {
    print_separator
    echo -e "${GREEN}✓ 极光导航部署成功！${NC}"
    print_separator

    # 获取服务器 IP
    SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")

    echo -e "${CYAN}访问信息:${NC}"
    echo -e "  本地访问: ${GREEN}http://localhost:${PORT}${NC}"
    if [ "$SERVER_IP" != "localhost" ]; then
        echo -e "  远程访问: ${GREEN}http://${SERVER_IP}:${PORT}${NC}"
    fi
    echo ""
    echo -e "${CYAN}容器信息:${NC}"
    echo -e "  应用容器: ${CONTAINER_NAME}"
    echo -e "  MySQL 容器: ${MYSQL_CONTAINER_NAME}"
    echo -e "  镜像名称: ${IMAGE_NAME}:latest"
    echo ""
    echo -e "${CYAN}数据库信息:${NC}"
    echo -e "  数据库: ${MYSQL_DATABASE}"
    echo -e "  用户: ${MYSQL_USER}"
    echo -e "  连接地址: ${MYSQL_HOST}:${MYSQL_PORT}"
    echo ""
    echo -e "${CYAN}常用命令:${NC}"
    echo -e "  查看日志: ${YELLOW}docker logs -f ${CONTAINER_NAME}${NC}"
    echo -e "  停止服务: ${YELLOW}docker compose down${NC}"
    echo -e "  启动服务: ${YELLOW}docker compose up -d${NC}"
    echo -e "  重启服务: ${YELLOW}docker compose restart${NC}"
    echo -e "  查看状态: ${YELLOW}docker ps${NC}"

    print_separator
}

# 主函数
main() {
    clear
    print_separator
    echo -e "${GREEN}极光导航 - Debian 12 简化部署脚本${NC}"
    echo -e "${CYAN}适用于已有 Docker 和 MySQL 容器的环境${NC}"
    print_separator

    # 检查环境
    check_docker
    check_docker_compose
    check_mysql_container
    test_mysql_connection
    check_nodejs

    # 安装依赖并初始化
    install_dependencies
    init_database
    migrate_sqlite_data

    # 构建并启动
    stop_old_container
    build_image
    start_container
    check_container_status
    configure_firewall

    # 显示信息
    show_deployment_info

    # 询问是否查看日志
    echo ""
    read -p "是否查看容器日志？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}按 Ctrl+C 退出日志查看${NC}"
        sleep 2
        docker logs -f ${CONTAINER_NAME}
    fi
}

# 错误处理
trap 'print_error "脚本执行出错"; exit 1' ERR

# 运行主函数
main
