#!/usr/bin/env pwsh
# MySQL Database Initialization Script for Docker

Write-Host "Initializing MySQL database via Docker container..." -ForegroundColor Cyan
Write-Host ""

# 检查 MySQL 容器是否在运行
Write-Host "Checking MySQL container status..." -ForegroundColor Yellow
$container = docker ps --filter "name=mysql" --format "{{.Names}}" 2>$null | Select-String "mysql"

if (-not $container) {
    Write-Host "ERROR: MySQL container is not running." -ForegroundColor Red
    Write-Host "Please start the MySQL container first." -ForegroundColor Red
    exit 1
}

Write-Host "MySQL container is running: $container" -ForegroundColor Green
Write-Host ""

# 步骤 1: 创建数据库和用户
Write-Host "Step 1: Creating database and user..." -ForegroundColor Yellow
$createDbCmd = "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;"

docker exec -i mysql mysql -u root -plh116688257 -e $createDbCmd 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create database and user." -ForegroundColor Red
    exit 1
}

Write-Host "Database and user created successfully!" -ForegroundColor Green
Write-Host ""

# 步骤 2: 创建表结构
Write-Host "Step 2: Creating tables..." -ForegroundColor Yellow
Get-Content init-mysql-tables.sql | docker exec -i mysql mysql -u root -plh116688257 nav

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create tables." -ForegroundColor Red
    exit 1
}

Write-Host "Tables created successfully!" -ForegroundColor Green
Write-Host ""

# 验证数据库
Write-Host "Verifying database..." -ForegroundColor Yellow
docker exec -i mysql mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;"

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Database initialized successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "Database: nav"
Write-Host "User: nav"
Write-Host "Password: lh116688257"
Write-Host ""
Write-Host "You can now restart the application:" -ForegroundColor Cyan
Write-Host "  docker-compose restart nav" -ForegroundColor White
Write-Host ""
