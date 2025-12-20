#!/bin/bash

set -e

echo "========================================="
echo "强制重建并重启 nav 应用"
echo "========================================="
echo ""

# 1. 停止并删除容器
echo "步骤 1: 停止并删除现有容器..."
docker-compose down
docker rm -f nav 2>/dev/null || true
echo "✓ 容器已删除"
echo ""

# 2. 删除旧镜像
echo "步骤 2: 删除旧镜像..."
docker rmi nav:latest 2>/dev/null || true
echo "✓ 旧镜像已删除"
echo ""

# 3. 检查 MySQL
echo "步骤 3: 检查 MySQL 容器..."
if ! docker ps | grep -q mysql; then
    echo "❌ MySQL 容器未运行"
    exit 1
fi
echo "✓ MySQL 容器运行中"
echo ""

# 4. 初始化数据库（如果需要）
echo "步骤 4: 确保 MySQL 数据库已初始化..."
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>&1 | grep -v "Using a password"
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257';" 2>&1 | grep -v "Using a password" || true
docker exec -i mysql mysql -u root -plh116688257 -e "GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;" 2>&1 | grep -v "Using a password"

if [ -f "init-mysql-tables.sql" ]; then
    echo "创建表结构..."
    docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql 2>&1 | grep -v "Using a password" || true
fi
echo "✓ 数据库已准备"
echo ""

# 5. 重新构建镜像
echo "步骤 5: 重新构建镜像（无缓存）..."
docker-compose build --no-cache
echo "✓ 镜像构建完成"
echo ""

# 6. 启动容器
echo "步骤 6: 启动容器..."
docker-compose up -d
echo "✓ 容器已启动"
echo ""

# 7. 等待并查看日志
echo "步骤 7: 查看启动日志..."
sleep 2
echo ""
echo "========== 容器日志（最近 50 行）=========="
docker-compose logs --tail=50 nav
echo "==========================================="
echo ""

# 8. 检查容器状态
echo "步骤 8: 检查容器状态..."
docker-compose ps
echo ""

# 9. 显示访问信息
echo "========================================="
echo "✓ 重建完成！"
echo "========================================="
echo ""
echo "访问地址："
echo "  http://localhost:3000"
echo "  http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "实时日志："
echo "  docker-compose logs -f nav"
echo ""
echo "验证 MySQL 连接："
echo "  docker exec nav env | grep DATABASE_URL"
echo ""
echo "检查数据库表："
echo "  docker exec -i mysql mysql -u nav -plh116688257 nav -e 'SHOW TABLES;'"
echo ""
