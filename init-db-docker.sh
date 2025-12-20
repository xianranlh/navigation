#!/bin/bash
# MySQL Database Initialization Script for Docker

echo -e "\033[36mInitializing MySQL database via Docker container...\033[0m"
echo ""

# 检查 MySQL 容器是否在运行
echo -e "\033[33mChecking MySQL container status...\033[0m"
CONTAINER=$(docker ps --filter "name=mysql" --format "{{.Names}}" | grep mysql)

if [ -z "$CONTAINER" ]; then
    echo -e "\033[31mERROR: MySQL container is not running.\033[0m"
    echo -e "\033[31mPlease start the MySQL container first.\033[0m"
    exit 1
fi

echo -e "\033[32mMySQL container is running: $CONTAINER\033[0m"
echo ""

# 步骤 1: 创建数据库和用户
echo -e "\033[33mStep 1: Creating database and user...\033[0m"
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;"

if [ $? -ne 0 ]; then
    echo -e "\033[31mERROR: Failed to create database and user.\033[0m"
    exit 1
fi

echo -e "\033[32mDatabase and user created successfully!\033[0m"
echo ""

# 步骤 2: 创建表结构
echo -e "\033[33mStep 2: Creating tables...\033[0m"
docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql

if [ $? -ne 0 ]; then
    echo -e "\033[31mERROR: Failed to create tables.\033[0m"
    exit 1
fi

echo -e "\033[32mTables created successfully!\033[0m"
echo ""

# 验证数据库
echo -e "\033[33mVerifying database...\033[0m"
docker exec -i mysql mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;"

echo ""
echo -e "\033[32m============================================\033[0m"
echo -e "\033[32mDatabase initialized successfully!\033[0m"
echo -e "\033[32m============================================\033[0m"
echo "Database: nav"
echo "User: nav"
echo "Password: lh116688257"
echo ""
echo -e "\033[36mYou can now restart the application:\033[0m"
echo -e "\033[37m  docker-compose restart nav\033[0m"
echo ""
