#!/bin/bash

echo "Initializing MySQL database for nav..."
echo ""

# 检查 MySQL 是否在运行
echo "Checking MySQL connection..."
if ! mysql -u root -plh116688257 -e "SELECT 'MySQL is running' as status;" 2>/dev/null; then
    echo "ERROR: Cannot connect to MySQL. Please make sure MySQL is running on port 3306."
    exit 1
fi

echo "MySQL connection successful!"
echo ""

# 执行初始化脚本
echo "Creating database and tables..."
if ! mysql -u root -plh116688257 < init-mysql.sql; then
    echo "ERROR: Failed to initialize database."
    exit 1
fi

echo ""
echo "Database initialized successfully!"
echo ""
echo "Database: nav"
echo "User: nav"
echo "Password: lh116688257"
echo ""

# 验证数据库是否创建成功
echo "Verifying database..."
if ! mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;"; then
    echo "ERROR: Failed to verify database."
    exit 1
fi

echo ""
echo "All done! You can now start the application with: docker-compose up -d"
