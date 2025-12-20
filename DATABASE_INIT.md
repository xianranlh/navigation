# MySQL 数据库初始化指南

## 前提条件
- MySQL 已安装并运行在 3306 端口
- Root 密码：lh116688257

## 初始化步骤

### 方式 1：使用 MySQL 命令行（推荐）

如果您已安装 MySQL 客户端工具，在项目根目录执行：

```bash
mysql -h 127.0.0.1 -u root -plh116688257 < init-mysql.sql
```

### 方式 2：使用 MySQL Workbench

1. 打开 MySQL Workbench
2. 连接到本地 MySQL 服务器（Host: 127.0.0.1, Port: 3306, User: root, Password: lh116688257）
3. 打开 `init-mysql.sql` 文件
4. 执行整个脚本

### 方式 3：手动执行 SQL 命令

登录 MySQL：
```bash
mysql -h 127.0.0.1 -u root -plh116688257
```

然后依次执行以下命令：
```sql
CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
FLUSH PRIVILEGES;
USE nav;
```

然后执行 `init-mysql.sql` 文件中的建表语句。

### 方式 4：在 Docker 容器启动后使用 Prisma

如果您不想手动创建表，可以：

1. 先手动创建数据库和用户：
```sql
CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
FLUSH PRIVILEGES;
```

2. 然后在项目中使用 Prisma 迁移：
```bash
# 在本地执行
DATABASE_URL="mysql://nav:lh116688257@127.0.0.1:3306/nav" npx prisma db push

# 或者在容器中执行
docker exec -it nav npx prisma db push
```

## 验证安装

初始化完成后，验证数据库：

```bash
mysql -h 127.0.0.1 -u root -plh116688257 -e "USE nav; SHOW TABLES;"
```

应该看到 8 个表：
- Category
- Countdown
- CustomFont
- GlobalSettings
- Site
- Todo
- User
- Wallpaper

## 启动应用

数据库初始化完成后，启动 Docker 容器：

```bash
docker-compose up -d
```

查看日志确认连接成功：
```bash
docker-compose logs -f nav
```

## 常见问题

### 问题 1：无法连接到 MySQL
- 确认 MySQL 服务正在运行
- 检查防火墙是否允许 3306 端口
- 确认 root 密码正确

### 问题 2：用户已存在错误
如果提示用户已存在，先删除：
```sql
DROP USER IF EXISTS 'nav'@'%';
```
然后重新创建。

### 问题 3：权限问题
如果遇到权限问题：
```sql
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
FLUSH PRIVILEGES;
```
