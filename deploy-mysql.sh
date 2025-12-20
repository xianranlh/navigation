#!/bin/bash

set -e  # 遇到错误立即退出

echo "========================================="
echo "完全重新部署 nav 应用（使用 MySQL）"
echo "========================================="
echo ""

# 步骤 1: 停止并删除现有容器
echo "步骤 1: 停止并删除现有容器..."
docker-compose down
echo "✓ 容器已停止"
echo ""

# 步骤 2: 检查 MySQL 容器
echo "步骤 2: 检查 MySQL 容器状态..."
if ! docker ps | grep -q mysql; then
    echo "❌ 错误: MySQL 容器未运行"
    echo "请先启动 MySQL 容器"
    exit 1
fi
echo "✓ MySQL 容器正在运行"
echo ""

# 步骤 3: 初始化 MySQL 数据库
echo "步骤 3: 初始化 MySQL 数据库..."
echo "创建数据库和用户..."
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;" 2>&1 | grep -v "Using a password"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ 数据库和用户创建成功"
else
    echo "⚠ 数据库和用户可能已存在（这是正常的）"
fi

echo "创建表结构..."
if [ -f "init-mysql-tables.sql" ]; then
    docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql 2>&1 | grep -v "Using a password"
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "✓ 表结构创建成功"
    else
        echo "⚠ 表可能已存在（这是正常的）"
    fi
else
    echo "⚠ 未找到 init-mysql-tables.sql，跳过表创建"
fi

echo "验证数据库..."
docker exec -i mysql mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;" 2>&1 | grep -v "Using a password"
echo ""

# 步骤 4: 重新构建镜像
echo "步骤 4: 重新构建 Docker 镜像（这可能需要几分钟）..."
docker-compose build --no-cache
echo "✓ 镜像构建完成"
echo ""

# 步骤 5: 启动应用
echo "步骤 5: 启动应用容器..."
docker-compose up -d
echo "✓ 容器已启动"
echo ""

# 步骤 6: 等待应用启动并查看日志
echo "步骤 6: 等待应用启动..."
echo "查看启动日志（10秒）..."
sleep 3
docker-compose logs --tail=30 nav

echo ""
echo "========================================="
echo "✓ 部署完成！"
echo "========================================="
echo ""
echo "检查应用状态："
echo "  docker-compose ps"
echo ""
echo "查看实时日志："
echo "  docker-compose logs -f nav"
echo ""
echo "访问应用："
echo "  http://localhost:12266"
echo "  或 http://服务器IP:12266"
echo ""
echo "验证 MySQL 连接："
echo "  docker exec -i mysql mysql -u nav -plh116688257 nav -e 'SHOW TABLES;'"
echo ""
