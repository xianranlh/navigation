#!/bin/bash

# 从 SQLite dev.db 创建 MySQL 数据库和表结构
# 并导入所有数据

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# MySQL 配置
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="nav"
MYSQL_PASSWORD="lh116688257"
MYSQL_DATABASE="nav"

# SQLite 数据库路径
SQLITE_DB="prisma/dev.db"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_separator() {
    echo -e "${BLUE}========================================${NC}"
}

# 检查 SQLite 数据库
check_sqlite_db() {
    print_info "检查 SQLite 数据库..."

    if [ ! -f "$SQLITE_DB" ]; then
        print_error "SQLite 数据库不存在: $SQLITE_DB"
        exit 1
    fi

    print_success "找到 SQLite 数据库: $SQLITE_DB"
}

# 检查 MySQL 连接
check_mysql() {
    print_info "检查 MySQL 连接..."

    if ! command -v mysql &> /dev/null; then
        print_error "未找到 mysql 命令"
        exit 1
    fi

    if mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &> /dev/null; then
        print_success "MySQL 连接成功"
    else
        print_error "MySQL 连接失败"
        exit 1
    fi
}

# 创建数据库
create_database() {
    print_separator
    print_info "创建 MySQL 数据库..."

    mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

    print_success "数据库创建成功: ${MYSQL_DATABASE}"
}

# 使用 SQL 文件创建表结构
create_tables() {
    print_separator
    print_info "创建 MySQL 表结构..."

    if [ ! -f "init-mysql-schema.sql" ]; then
        print_error "未找到 init-mysql-schema.sql 文件"
        exit 1
    fi

    mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" < init-mysql-schema.sql

    print_success "表结构创建成功"
}

# 使用 Prisma 创建表结构 (备用方案)
create_tables_with_prisma() {
    print_separator
    print_info "使用 Prisma 创建表结构..."

    export DATABASE_URL="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"

    if [ ! -d "node_modules" ]; then
        print_info "安装依赖..."
        npm install
    fi

    npx prisma generate
    npx prisma db push --accept-data-loss

    print_success "Prisma 表结构创建成功"
}

# 导入数据
import_data() {
    print_separator
    print_info "导入数据到 MySQL..."

    # 检查依赖
    if ! npm list sqlite3 &> /dev/null || ! npm list mysql2 &> /dev/null; then
        print_info "安装迁移依赖..."
        npm install --save-dev sqlite3 mysql2
    fi

    # 运行迁移脚本
    if node migrate-to-mysql.js; then
        print_success "数据导入成功"
    else
        print_error "数据导入失败"
        exit 1
    fi
}

# 验证数据
verify_data() {
    print_separator
    print_info "验证数据..."

    mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        -D"${MYSQL_DATABASE}" -e "
        SELECT 'Site' as TableName, COUNT(*) as Count FROM Site
        UNION ALL
        SELECT 'Category', COUNT(*) FROM Category
        UNION ALL
        SELECT 'User', COUNT(*) FROM User
        UNION ALL
        SELECT 'GlobalSettings', COUNT(*) FROM GlobalSettings
        UNION ALL
        SELECT 'Wallpaper', COUNT(*) FROM Wallpaper
        UNION ALL
        SELECT 'CustomFont', COUNT(*) FROM CustomFont
        UNION ALL
        SELECT 'Todo', COUNT(*) FROM Todo
        UNION ALL
        SELECT 'Countdown', COUNT(*) FROM Countdown;
    "

    print_success "数据验证完成"
}

# 主函数
main() {
    print_separator
    echo -e "${GREEN}SQLite 到 MySQL 数据库迁移工具${NC}"
    print_separator

    check_sqlite_db
    check_mysql
    create_database

    # 尝试使用 SQL 文件创建表,失败则使用 Prisma
    if ! create_tables 2>/dev/null; then
        print_info "SQL 文件创建失败,使用 Prisma..."
        create_tables_with_prisma
    fi

    import_data
    verify_data

    print_separator
    echo -e "${GREEN}✓ 迁移完成!${NC}"
    echo -e "${BLUE}数据库:${NC} ${MYSQL_DATABASE}"
    echo -e "${BLUE}主机:${NC} ${MYSQL_HOST}:${MYSQL_PORT}"
    print_separator
}

main
