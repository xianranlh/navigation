#!/bin/bash

echo "Initializing MySQL database for nav..."
echo ""

# 检查 MySQL 容器是否在运行
echo "Checking MySQL container status..."
if ! docker ps | grep -q mysql; then
    echo "ERROR: MySQL container is not running."
    echo "Please start the MySQL container first."
    exit 1
fi

echo "MySQL container is running."
echo ""

# 步骤 1: 创建数据库和用户
echo "Step 1: Creating database and user..."
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;" 2>&1 | grep -v "Using a password on the command line"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "ERROR: Failed to create database and user."
    exit 1
fi

echo "Database and user created successfully!"
echo ""

# 步骤 2: 创建表结构
echo "Step 2: Creating tables..."
docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql 2>&1 | grep -v "Using a password on the command line"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "ERROR: Failed to create tables."
    exit 1
fi

echo "Tables created successfully!"
echo ""

# 验证数据库
echo "Verifying database..."
docker exec -i mysql mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;" 2>&1 | grep -v "Using a password on the command line"

echo ""
echo "============================================"
echo "Database initialized successfully!"
echo "============================================"
echo "Database: nav"
echo "User: nav"
echo "Password: lh116688257"
echo ""
echo "You can now restart the application:"
echo "  docker-compose restart nav"
echo ""
