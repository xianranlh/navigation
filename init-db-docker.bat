@echo off
echo Initializing MySQL database via Docker container...
echo.

REM 检查 MySQL 容器是否在运行
echo Checking MySQL container status...
docker ps --filter "name=mysql" --format "{{.Names}}" | findstr "mysql" >nul
if errorlevel 1 (
    echo ERROR: MySQL container is not running.
    echo Please start the MySQL container first.
    pause
    exit /b 1
)

echo MySQL container is running.
echo.

REM 步骤 1: 创建数据库和用户
echo Step 1: Creating database and user...
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%%'; FLUSH PRIVILEGES;"
if errorlevel 1 (
    echo ERROR: Failed to create database and user.
    pause
    exit /b 1
)

echo Database and user created successfully!
echo.

REM 步骤 2: 创建表结构
echo Step 2: Creating tables...
docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql
if errorlevel 1 (
    echo ERROR: Failed to create tables.
    pause
    exit /b 1
)

echo Tables created successfully!
echo.

REM 验证数据库
echo Verifying database...
docker exec -i mysql mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;"

echo.
echo ============================================
echo Database initialized successfully!
echo ============================================
echo Database: nav
echo User: nav
echo Password: lh116688257
echo.
echo You can now restart the application:
echo   docker-compose restart nav
echo.
pause
