# 切换到 MySQL 数据库 - 部署指南

## 问题说明

应用之前使用 SQLite 数据库，现在需要切换到 MySQL。主要问题：
1. ✅ Prisma schema 已更新为 MySQL
2. ✅ docker-compose.yml 已配置 MySQL 连接
3. ✅ entrypoint.sh 已更新支持 MySQL
4. ⚠️ 需要重新构建镜像并初始化 MySQL 数据库

## 快速部署步骤

### 方式 1：使用自动化脚本（推荐）

```bash
chmod +x redeploy-with-mysql.sh
./redeploy-with-mysql.sh
```

这个脚本会自动完成以下操作：
- 停止并删除现有容器
- 可选删除 SQLite 数据卷
- 重新构建 Docker 镜像
- 初始化 MySQL 数据库
- 启动应用

### 方式 2：手动执行步骤

**步骤 1：停止并删除现有容器**
```bash
docker-compose down
```

**步骤 2：删除旧的 SQLite 数据卷（可选）**
```bash
# 警告：这会删除所有现有数据！
docker volume rm navigation_data
# 或
docker volume rm data
```

如果提示 "volume is in use"，先确保容器已完全停止：
```bash
docker ps -a | grep nav
docker rm -f nav  # 如果容器还在运行
```

**步骤 3：重新构建 Docker 镜像**
```bash
docker-compose build --no-cache
```

**步骤 4：初始化 MySQL 数据库**

执行初始化脚本：
```bash
./init-mysql.sh
```

或手动执行命令：
```bash
# 创建数据库和用户
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;"

# 创建表结构
docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql

# 验证
docker exec -i mysql mysql -u root -plh116688257 -e "USE nav; SHOW TABLES;"
```

**步骤 5：启动应用**
```bash
docker-compose up -d
```

**步骤 6：查看日志验证**
```bash
docker-compose logs -f nav
```

您应该看到：
- ✅ "使用 MySQL 数据库"
- ✅ "DATABASE_URL: mysql://nav:lh116688257@host.docker.internal:3306/nav"
- ✅ 应用正常启动

## 验证 MySQL 连接

### 检查日志
```bash
docker-compose logs nav | grep -i mysql
docker-compose logs nav | grep -i database
```

### 连接到 MySQL 验证数据
```bash
docker exec -i mysql mysql -u nav -plh116688257 nav -e "SHOW TABLES;"
```

### 测试应用
访问 http://localhost:12266（或您的服务器 IP:12266）

## 故障排除

### 问题 1：容器无法连接到 MySQL
**症状：** 日志显示连接错误

**解决方案：**
```bash
# 检查 MySQL 容器是否运行
docker ps | grep mysql

# 检查网络连接
docker exec nav ping host.docker.internal -c 3

# 如果 ping 失败，检查 extra_hosts 配置
docker inspect nav | grep -A 5 ExtraHosts
```

### 问题 2：数据库不存在
**症状：** "Unknown database 'nav'"

**解决方案：**
```bash
# 重新运行数据库初始化
./init-mysql.sh
```

### 问题 3：权限错误
**症状：** "Access denied for user 'nav'"

**解决方案：**
```bash
docker exec -i mysql mysql -u root -plh116688257 -e "GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;"
```

### 问题 4：旧数据卷无法删除
**症状：** "volume is in use"

**解决方案：**
```bash
# 1. 停止所有相关容器
docker-compose down
docker ps -a | grep nav

# 2. 强制删除容器
docker rm -f nav

# 3. 删除卷
docker volume rm navigation_data data
```

## 数据迁移（如果需要保留 SQLite 数据）

如果您需要将 SQLite 数据迁移到 MySQL：

```bash
# 1. 导出 SQLite 数据（在容器外）
sqlite3 data/dev.db .dump > sqlite_dump.sql

# 2. 转换并导入 MySQL（需要手动调整 SQL 语法）
# SQLite 和 MySQL 语法有差异，需要手动处理
```

## 环境变量说明

应用通过 `DATABASE_URL` 环境变量确定使用哪个数据库：

- **MySQL**: `mysql://nav:lh116688257@host.docker.internal:3306/nav`
- **SQLite**: `file:/app/data/dev.db`

当前配置在 [docker-compose.yml](docker-compose.yml:10) 第 10 行。

## 文件说明

修改的文件：
- ✅ [prisma/schema.prisma](prisma/schema.prisma) - 数据库提供者改为 MySQL
- ✅ [docker-compose.yml](docker-compose.yml) - MySQL 连接配置
- ✅ [entrypoint.sh](entrypoint.sh) - 支持 MySQL 和 SQLite

新增的文件：
- [init-mysql.sh](init-mysql.sh) - MySQL 数据库初始化脚本
- [init-mysql-tables.sql](init-mysql-tables.sql) - 表结构 SQL
- [redeploy-with-mysql.sh](redeploy-with-mysql.sh) - 自动化重新部署脚本
- [MYSQL_DEPLOYMENT.md](MYSQL_DEPLOYMENT.md) - 本文档

## 回滚到 SQLite（如果需要）

如果需要回滚到 SQLite：

```bash
# 1. 修改 docker-compose.yml
# 将 DATABASE_URL 改为: file:/app/data/dev.db

# 2. 修改 prisma/schema.prisma
# 将 provider 改为: sqlite

# 3. 重新构建和启动
docker-compose down
docker-compose build
docker-compose up -d
```
