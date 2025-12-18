-- 极光导航 MySQL 数据库初始化脚本
-- 根据 Prisma Schema 生成

-- 创建数据库 (如果不存在)
CREATE DATABASE IF NOT EXISTS `nav` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `nav`;

-- 删除已存在的表 (按依赖关系逆序删除)
DROP TABLE IF EXISTS `Countdown`;
DROP TABLE IF EXISTS `Todo`;
DROP TABLE IF EXISTS `CustomFont`;
DROP TABLE IF EXISTS `Wallpaper`;
DROP TABLE IF EXISTS `GlobalSettings`;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS `Category`;
DROP TABLE IF EXISTS `Site`;

-- 创建 Site 表
CREATE TABLE `Site` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `url` VARCHAR(500) NOT NULL,
    `desc` TEXT NULL,
    `category` VARCHAR(100) NOT NULL,
    `color` VARCHAR(50) NULL,
    `icon` VARCHAR(255) NULL,
    `iconType` VARCHAR(50) NULL,
    `customIconUrl` VARCHAR(500) NULL,
    `titleFont` VARCHAR(100) NULL,
    `descFont` VARCHAR(100) NULL,
    `titleColor` VARCHAR(50) NULL,
    `descColor` VARCHAR(50) NULL,
    `titleSize` INT NULL,
    `descSize` INT NULL,
    `isHidden` BOOLEAN NOT NULL DEFAULT false,
    `order` INT NOT NULL DEFAULT 0,
    `type` VARCHAR(50) NOT NULL DEFAULT 'site',
    `parentId` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`),
    INDEX `idx_category` (`category`),
    INDEX `idx_order` (`order`),
    INDEX `idx_parentId` (`parentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 Category 表
CREATE TABLE `Category` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `color` VARCHAR(50) NULL,
    `isHidden` BOOLEAN NOT NULL DEFAULT false,
    `order` INT NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`),
    UNIQUE KEY `Category_name_unique` (`name`),
    INDEX `idx_order` (`order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 User 表
CREATE TABLE `User` (
    `username` VARCHAR(100) NOT NULL,
    `passwordHash` VARCHAR(255) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 GlobalSettings 表
CREATE TABLE `GlobalSettings` (
    `id` INT NOT NULL DEFAULT 1,
    `layout` TEXT NOT NULL,
    `config` TEXT NOT NULL,
    `theme` TEXT NOT NULL,
    `searchEngine` VARCHAR(50) NOT NULL DEFAULT 'Google',
    `bingCacheMode` VARCHAR(50) NOT NULL DEFAULT 'keep-all',
    `privatePasswordHash` VARCHAR(255) NULL,
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 Wallpaper 表
CREATE TABLE `Wallpaper` (
    `id` VARCHAR(191) NOT NULL,
    `url` VARCHAR(500) NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `filename` VARCHAR(255) NOT NULL,
    `size` INT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_createdAt` (`createdAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 CustomFont 表
CREATE TABLE `CustomFont` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `family` VARCHAR(100) NOT NULL,
    `url` VARCHAR(500) NOT NULL,
    `provider` VARCHAR(50) NOT NULL DEFAULT 'google',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`),
    INDEX `idx_provider` (`provider`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 Todo 表
CREATE TABLE `Todo` (
    `id` VARCHAR(191) NOT NULL,
    `text` TEXT NOT NULL,
    `done` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`),
    INDEX `idx_done` (`done`),
    INDEX `idx_createdAt` (`createdAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建 Countdown 表
CREATE TABLE `Countdown` (
    `id` VARCHAR(191) NOT NULL,
    `label` VARCHAR(255) NOT NULL,
    `date` VARCHAR(50) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`),
    INDEX `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认的 GlobalSettings
INSERT INTO `GlobalSettings` (`id`, `layout`, `config`, `theme`, `searchEngine`, `bingCacheMode`)
VALUES (1, '{}', '{}', '{}', 'Google', 'keep-all')
ON DUPLICATE KEY UPDATE `id` = `id`;
