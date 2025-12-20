#!/bin/bash

# ============================================
# MySQL 数据库初始化脚本
# 用于在已有的 MySQL 容器中创建 nav 数据库和表
# 适用于 Debian GNU/Linux 12
# ============================================

# 配置变量（根据实际情况修改）
MYSQL_CONTAINER_NAME="mysql"  # 已有的 MySQL 容器名称
MYSQL_ROOT_PASSWORD="lh116688257"
DATABASE_NAME="nav"

echo "=========================================="
echo "Navigation MySQL 数据库初始化"
echo "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装或未在 PATH 中"
    exit 1
fi

# 检查 MySQL 容器是否运行
if ! docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER_NAME}$"; then
    echo "错误: MySQL 容器 '${MYSQL_CONTAINER_NAME}' 未运行"
    echo "请先启动 MySQL 容器或修改脚本中的 MYSQL_CONTAINER_NAME 变量"
    exit 1
fi

echo "✓ 检测到 MySQL 容器: ${MYSQL_CONTAINER_NAME}"

# 创建数据库
echo ""
echo "正在创建数据库 '${DATABASE_NAME}'..."
docker exec -i ${MYSQL_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<EOF
CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF

if [ $? -ne 0 ]; then
    echo "错误: 数据库创建失败"
    exit 1
fi
echo "✓ 数据库创建成功"

# 创建表结构
echo ""
echo "正在创建表结构..."
docker exec -i ${MYSQL_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${DATABASE_NAME} <<EOF
-- Site 表
CREATE TABLE IF NOT EXISTS \`Site\` (
  \`id\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`name\` VARCHAR(191) NOT NULL,
  \`url\` VARCHAR(191) NOT NULL,
  \`desc\` TEXT,
  \`category\` VARCHAR(191) NOT NULL,
  \`color\` VARCHAR(191),
  \`icon\` VARCHAR(191),
  \`iconType\` VARCHAR(191),
  \`customIconUrl\` TEXT,
  \`titleFont\` VARCHAR(191),
  \`descFont\` VARCHAR(191),
  \`titleColor\` VARCHAR(191),
  \`descColor\` VARCHAR(191),
  \`titleSize\` INT,
  \`descSize\` INT,
  \`isHidden\` BOOLEAN NOT NULL DEFAULT false,
  \`order\` INT NOT NULL DEFAULT 0,
  \`type\` VARCHAR(191) NOT NULL DEFAULT 'site',
  \`parentId\` VARCHAR(191),
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updatedAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Category 表
CREATE TABLE IF NOT EXISTS \`Category\` (
  \`id\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`name\` VARCHAR(191) NOT NULL UNIQUE,
  \`color\` VARCHAR(191),
  \`isHidden\` BOOLEAN NOT NULL DEFAULT false,
  \`order\` INT NOT NULL DEFAULT 0,
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updatedAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User 表
CREATE TABLE IF NOT EXISTS \`User\` (
  \`username\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`passwordHash\` VARCHAR(191) NOT NULL,
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updatedAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- GlobalSettings 表
CREATE TABLE IF NOT EXISTS \`GlobalSettings\` (
  \`id\` INT NOT NULL PRIMARY KEY DEFAULT 1,
  \`layout\` TEXT NOT NULL,
  \`config\` TEXT NOT NULL,
  \`theme\` TEXT NOT NULL,
  \`searchEngine\` VARCHAR(191) NOT NULL DEFAULT 'Google',
  \`bingCacheMode\` VARCHAR(191) NOT NULL DEFAULT 'keep-all',
  \`privatePasswordHash\` VARCHAR(191),
  \`updatedAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wallpaper 表
CREATE TABLE IF NOT EXISTS \`Wallpaper\` (
  \`id\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`url\` VARCHAR(191) NOT NULL,
  \`type\` VARCHAR(191) NOT NULL,
  \`filename\` VARCHAR(191) NOT NULL,
  \`size\` INT,
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CustomFont 表
CREATE TABLE IF NOT EXISTS \`CustomFont\` (
  \`id\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`name\` VARCHAR(191) NOT NULL,
  \`family\` VARCHAR(191) NOT NULL,
  \`url\` VARCHAR(191) NOT NULL,
  \`provider\` VARCHAR(191) NOT NULL DEFAULT 'google',
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Todo 表
CREATE TABLE IF NOT EXISTS \`Todo\` (
  \`id\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`text\` VARCHAR(191) NOT NULL,
  \`done\` BOOLEAN NOT NULL DEFAULT false,
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updatedAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Countdown 表
CREATE TABLE IF NOT EXISTS \`Countdown\` (
  \`id\` VARCHAR(191) NOT NULL PRIMARY KEY,
  \`label\` VARCHAR(191) NOT NULL,
  \`date\` VARCHAR(191) NOT NULL,
  \`createdAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  \`updatedAt\` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF

if [ $? -ne 0 ]; then
    echo "错误: 表结构创建失败"
    exit 1
fi

echo "✓ 表结构创建成功"

# 显示表信息
echo ""
echo "数据库表列表:"
docker exec -i ${MYSQL_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${DATABASE_NAME} -e "SHOW TABLES;"

echo ""
echo "=========================================="
echo "✓ 数据库初始化完成!"
echo "=========================================="
echo ""
echo "下一步，启动 nav 应用:"
echo "  docker-compose up -d --build"
