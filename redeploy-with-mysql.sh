#!/bin/bash

echo "==================================="
echo "Redeploying nav with MySQL"
echo "==================================="
echo ""

# 停止并删除容器
echo "Step 1: Stopping and removing containers..."
docker-compose down

# 删除旧的 data 卷（SQLite 数据）
echo ""
echo "Step 2: Removing old SQLite data volume..."
read -p "This will delete all existing data in the volume. Continue? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume rm navigation_data 2>/dev/null || docker volume rm data 2>/dev/null || echo "Volume already removed or doesn't exist"
else
    echo "Keeping existing volume..."
fi

# 重新构建镜像
echo ""
echo "Step 3: Rebuilding Docker image..."
docker-compose build --no-cache

# 初始化 MySQL 数据库
echo ""
echo "Step 4: Initializing MySQL database..."
if [ -f "init-mysql.sh" ]; then
    sh init-mysql.sh
else
    echo "Running manual database initialization..."

    # 创建数据库和用户
    docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;" 2>&1 | grep -v "Using a password"

    # 创建表
    if [ -f "init-mysql-tables.sql" ]; then
        docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql 2>&1 | grep -v "Using a password"
    fi
fi

# 启动应用
echo ""
echo "Step 5: Starting application..."
docker-compose up -d

# 等待应用启动
echo ""
echo "Waiting for application to start..."
sleep 5

# 查看日志
echo ""
echo "Application logs:"
docker-compose logs --tail=50 nav

echo ""
echo "==================================="
echo "Deployment completed!"
echo "==================================="
echo ""
echo "Application is running at: http://localhost:12266"
echo ""
echo "To view logs: docker-compose logs -f nav"
echo "To stop: docker-compose down"
echo ""
