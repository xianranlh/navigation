#!/bin/bash

# 极光导航 - 一键打包并启动容器脚本 (MySQL 版本)
# Author: Claude Code
# Date: 2025-12-19

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目配置
IMAGE_NAME="jg_nav"
CONTAINER_NAME="jg_nav"
PORT="2266"

# MySQL 配置
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="nav"
MYSQL_PASSWORD="lh116688257"
MYSQL_DATABASE="nav"

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

# 打印分隔线
print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# 检查 Docker 是否安装
check_docker() {
    print_info "检查 Docker 环境..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker 未运行，请先启动 Docker"
        exit 1
    fi

    print_success "Docker 环境正常"
}

# 检查 docker-compose 是否安装
check_docker_compose() {
    print_info "检查 Docker Compose 环境..."
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    print_success "Docker Compose 环境正常"
}

# 检查 MySQL 连接
check_mysql() {
    print_info "检查 MySQL 连接..."

    if ! command -v mysql &> /dev/null; then
        print_warning "未找到 mysql 命令行工具，跳过 MySQL 检查"
        print_warning "请确保 MySQL 服务运行在 ${MYSQL_HOST}:${MYSQL_PORT}"
        return
    fi

    if mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &> /dev/null; then
        print_success "MySQL 连接成功"
    else
        print_error "MySQL 连接失败"
        print_error "请确保 MySQL 服务运行在 ${MYSQL_HOST}:${MYSQL_PORT}"
        print_error "用户名: ${MYSQL_USER}, 密码: ${MYSQL_PASSWORD}"
        exit 1
    fi
}

# 初始化 MySQL 数据库
init_mysql_database() {
    print_separator
    print_info "初始化 MySQL 数据库..."

    # 检查数据库是否存在
    DB_EXISTS=$(mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${MYSQL_DATABASE}'" \
        -s -N 2>/dev/null || echo "")

    if [ -z "$DB_EXISTS" ]; then
        print_info "数据库 '${MYSQL_DATABASE}' 不存在，正在创建..."
        mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
            -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        print_success "数据库创建成功"

        # 设置需要迁移数据的标志
        NEED_MIGRATION=true
    else
        print_info "数据库 '${MYSQL_DATABASE}' 已存在"

        # 检查是否有表
        TABLE_COUNT=$(mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
            -D"${MYSQL_DATABASE}" -e "SHOW TABLES" -s -N 2>/dev/null | wc -l)

        if [ "$TABLE_COUNT" -eq 0 ]; then
            print_info "数据库为空，需要初始化"
            NEED_MIGRATION=true
        else
            print_info "数据库已有 ${TABLE_COUNT} 个表"
            NEED_MIGRATION=false
        fi
    fi
}

# 运行 Prisma 迁移
run_prisma_migrate() {
    print_separator
    print_info "运行 Prisma 数据库迁移..."

    # 设置临时环境变量
    export DATABASE_URL="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"

    # 检查是否安装了 npm 依赖
    if [ ! -d "node_modules" ]; then
        print_info "安装 npm 依赖..."
        npm install
    fi

    # 运行 Prisma 迁移
    print_info "生成 Prisma Client..."
    npx prisma generate

    print_info "推送数据库架构..."
    npx prisma db push --accept-data-loss

    print_success "Prisma 迁移完成"
}

# 使用 SQL 文件初始化数据库 (备用方案)
init_mysql_with_sql() {
    print_separator
    print_info "使用 SQL 文件初始化数据库..."

    if [ ! -f "init-mysql-schema.sql" ]; then
        print_warning "未找到 init-mysql-schema.sql 文件"
        return 1
    fi

    if ! command -v mysql &> /dev/null; then
        print_error "未找到 mysql 命令行工具"
        return 1
    fi

    print_info "执行 SQL 初始化脚本..."
    mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" < init-mysql-schema.sql

    print_success "SQL 初始化完成"
}

# 迁移 SQLite 数据到 MySQL
migrate_data() {
    if [ "$NEED_MIGRATION" != "true" ]; then
        print_info "跳过数据迁移"
        return
    fi

    print_separator
    print_info "检查是否需要从 SQLite 迁移数据..."

    SQLITE_DB="prisma/dev.db"

    if [ ! -f "$SQLITE_DB" ]; then
        print_warning "未找到 SQLite 数据库文件: ${SQLITE_DB}"
        print_info "将创建空数据库"
        return
    fi

    print_info "发现 SQLite 数据库，准备迁移数据..."

    # 检查是否安装了必要的依赖
    if ! npm list sqlite3 &> /dev/null || ! npm list mysql2 &> /dev/null; then
        print_info "安装数据迁移依赖..."
        npm install --save-dev sqlite3 mysql2
    fi

    # 运行迁移脚本
    print_info "开始迁移数据..."
    if node migrate-to-mysql.js; then
        print_success "数据迁移成功"
    else
        print_warning "数据迁移失败，将使用空数据库"
    fi
}

# 停止并删除旧容器
stop_old_container() {
    print_info "检查旧容器..."
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_warning "发现旧容器，正在停止并删除..."
        docker-compose down -v 2>/dev/null || docker compose down -v 2>/dev/null || true
        print_success "旧容器已清理"
    else
        print_info "没有发现旧容器"
    fi
}

# 删除旧镜像（可选）
clean_old_images() {
    print_info "检查旧镜像..."
    if docker images | grep -q "^${IMAGE_NAME}"; then
        print_warning "发现旧镜像，正在删除..."
        docker rmi ${IMAGE_NAME}:latest 2>/dev/null || true
        print_success "旧镜像已删除"
    else
        print_info "没有发现旧镜像"
    fi
}

# 构建 Docker 镜像
build_image() {
    print_separator
    print_info "开始构建 Docker 镜像..."
    print_info "这可能需要几分钟时间，请耐心等待..."
    print_separator

    if docker-compose build --no-cache 2>/dev/null || docker compose build --no-cache; then
        print_success "Docker 镜像构建成功"
    else
        print_error "Docker 镜像构建失败"
        exit 1
    fi
}

# 启动容器
start_container() {
    print_separator
    print_info "启动容器..."

    if docker-compose up -d 2>/dev/null || docker compose up -d; then
        print_success "容器启动成功"
    else
        print_error "容器启动失败"
        exit 1
    fi
}

# 检查容器状态
check_container_status() {
    print_info "检查容器状态..."
    sleep 3  # 等待容器完全启动

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_success "容器运行正常"
        print_separator
        echo -e "${GREEN}✓ 部署成功！${NC}"
        echo -e "${BLUE}访问地址:${NC} http://localhost:${PORT}"
        echo -e "${BLUE}容器名称:${NC} ${CONTAINER_NAME}"
        print_separator
    else
        print_error "容器未正常运行"
        print_warning "正在查看容器日志..."
        docker logs ${CONTAINER_NAME} --tail 50
        exit 1
    fi
}

# 显示日志
show_logs() {
    print_info "查看容器日志 (按 Ctrl+C 退出)..."
    docker logs -f ${CONTAINER_NAME}
}

# 主函数
main() {
    print_separator
    echo -e "${GREEN}极光导航 - 一键部署脚本 (MySQL 版本)${NC}"
    print_separator

    # 执行部署流程
    check_docker
    check_docker_compose
    check_mysql
    init_mysql_database
    run_prisma_migrate
    migrate_data
    stop_old_container
    clean_old_images
    build_image
    start_container
    check_container_status

    # 询问是否查看日志
    echo ""
    read -p "是否查看容器日志？(y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        show_logs
    else
        print_info "部署完成！使用以下命令查看日志:"
        echo "  docker logs -f ${CONTAINER_NAME}"
    fi
}

# 运行主函数
main
