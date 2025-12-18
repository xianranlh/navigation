# 极光导航 - Debian 12 简化部署指南

> 适用于已有 Docker、Docker Compose 和 MySQL 容器的环境

## 📋 前置条件

在运行部署脚本前,请确保以下软件已安装:

- ✅ Docker (已安装并运行)
- ✅ Docker Compose (已安装)
- ✅ MySQL 容器 (已运行)
- ✅ Node.js 16+ (脚本会检查并提示)

## 🚀 快速部署

### 方法一: 使用简化脚本 (推荐)

```bash
# 1. 进入项目目录
cd /path/to/navigation

# 2. 运行简化部署脚本
bash debian12-deploy-simple.sh
```

### 方法二: 手动部署

```bash
# 1. 安装依赖
npm install

# 2. 配置环境变量
export DATABASE_URL="mysql://nav:lh116688257@host.docker.internal:3306/nav"

# 3. 初始化数据库
npx prisma generate
npx prisma db push

# 4. 构建并启动
docker compose build --no-cache
docker compose up -d
```

## 🎯 新端口配置

**应用端口已更改为: 13000**

- 本地访问: `http://localhost:13000`
- 远程访问: `http://your-server-ip:13000`

## 🔧 MySQL 容器配置

### 默认配置
```yaml
容器名称: mysql (脚本会自动检测)
数据库: nav
用户: nav
密码: lh116688257
端口: 3306
连接方式: host.docker.internal (从应用容器访问宿主机的 MySQL 容器)
```

### 常见 MySQL 容器名称
脚本会自动尝试检测以下容器名称:
- `mysql`
- `mysql-container`
- `mysql-server`
- `db`
- `mariadb`

如果您的 MySQL 容器使用其他名称,脚本会提示您输入。

## 📝 docker-compose.yml 配置说明

```yaml
services:
  jg_nav:
    image: jg_nav:latest
    build: .
    container_name: jg_nav
    ports:
      - "13000:3000"  # 外部端口改为 13000
    environment:
      - NODE_ENV=production
      - DATABASE_URL=mysql://nav:lh116688257@host.docker.internal:3306/nav
    extra_hosts:
      - "host.docker.internal:host-gateway"  # 允许容器访问宿主机
    volumes:
      - uploads:/app/public/uploads
    restart: unless-stopped
```

### 关键配置项说明

1. **端口映射**: `13000:3000`
   - 外部访问端口: 13000
   - 容器内部端口: 3000

2. **数据库连接**: `host.docker.internal:3306`
   - 使用 `host.docker.internal` 从容器访问宿主机上的 MySQL 容器
   - 需要配合 `extra_hosts` 使用

3. **数据持久化**:
   - 上传文件存储在 Docker 卷 `uploads` 中

## 🔍 脚本功能说明

### 简化部署脚本 (debian12-deploy-simple.sh)

这个脚本专为已有 Docker 和 MySQL 环境设计,会执行:

1. ✅ 检查 Docker 和 Docker Compose
2. ✅ 自动检测 MySQL 容器
3. ✅ 测试 MySQL 连接
4. ✅ 检查 Node.js 版本
5. ✅ 安装项目依赖
6. ✅ 初始化数据库 (使用 Prisma)
7. ✅ 迁移 SQLite 数据 (如果存在)
8. ✅ 构建 Docker 镜像
9. ✅ 启动应用容器
10. ✅ 配置防火墙 (如果需要)

### 完整安装脚本 (debian12-install.sh)

这个脚本适用于全新的 Debian 12 系统,会安装所有依赖:
- Docker & Docker Compose
- MySQL Server
- Node.js 18.x LTS
- 然后执行部署

## 📊 容器管理

### 查看运行状态
```bash
docker ps
```

### 查看应用日志
```bash
docker logs -f jg_nav
```

### 查看 MySQL 日志
```bash
docker logs -f mysql  # 根据实际容器名称修改
```

### 重启应用
```bash
docker compose restart
```

### 停止应用
```bash
docker compose down
```

### 启动应用
```bash
docker compose up -d
```

### 重新构建
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## 🗄️ MySQL 容器管理

### 进入 MySQL 容器
```bash
docker exec -it mysql bash  # 根据实际容器名称修改
```

### 连接到 MySQL
```bash
# 从容器外部
docker exec -it mysql mysql -unav -plh116688257 nav

# 或者使用 root 用户
docker exec -it mysql mysql -uroot -p
```

### 创建数据库 (如果不存在)
```bash
docker exec -it mysql mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 创建用户并授权
```bash
docker exec -it mysql mysql -uroot -p <<EOF
CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
FLUSH PRIVILEGES;
EOF
```

### 备份数据库
```bash
docker exec mysql mysqldump -unav -plh116688257 nav > backup_$(date +%Y%m%d).sql
```

### 恢复数据库
```bash
docker exec -i mysql mysql -unav -plh116688257 nav < backup_20231219.sql
```

## 🔧 故障排查

### 1. 应用无法连接到 MySQL

**问题**: 应用日志显示 "Can't connect to MySQL server"

**解决方案**:
```bash
# 检查 MySQL 容器是否运行
docker ps | grep mysql

# 检查 MySQL 容器网络
docker inspect mysql | grep IPAddress

# 测试从应用容器连接 MySQL
docker exec jg_nav sh -c "nc -zv host.docker.internal 3306"

# 确保 MySQL 允许远程连接
docker exec -it mysql mysql -uroot -p -e "SELECT host, user FROM mysql.user WHERE user='nav';"
```

### 2. 端口 13000 被占用

```bash
# 查看端口占用
netstat -tlnp | grep 13000
# 或
lsof -i :13000

# 停止占用端口的进程
kill -9 <PID>

# 或修改 docker-compose.yml 使用其他端口
```

### 3. 容器启动失败

```bash
# 查看详细日志
docker logs jg_nav --tail 100

# 查看容器状态
docker inspect jg_nav

# 重新构建
docker compose down
docker compose build --no-cache
docker compose up -d
```

### 4. Prisma 数据库推送失败

```bash
# 手动执行数据库迁移
export DATABASE_URL="mysql://nav:lh116688257@host.docker.internal:3306/nav"
npx prisma generate
npx prisma db push --accept-data-loss

# 如果仍然失败,检查 MySQL 连接
docker exec mysql mysql -unav -plh116688257 -e "SHOW DATABASES;"
```

### 5. 权限问题

```bash
# 确保 uploads 目录权限正确
docker exec jg_nav sh -c "chmod -R 777 /app/public/uploads"

# 重启容器
docker compose restart
```

## 🔒 安全建议

### 1. 修改默认密码

```bash
# 进入 MySQL 容器修改密码
docker exec -it mysql mysql -uroot -p

# 执行以下 SQL
ALTER USER 'nav'@'%' IDENTIFIED BY 'new_strong_password';
FLUSH PRIVILEGES;

# 然后更新 docker-compose.yml 中的 DATABASE_URL
# 和所有使用该密码的脚本
```

### 2. 限制端口访问

```bash
# 使用防火墙限制访问
ufw allow from 192.168.1.0/24 to any port 13000

# 或者只允许特定 IP
ufw allow from 192.168.1.100 to any port 13000
```

### 3. 使用反向代理

推荐使用 Nginx 或 Caddy 作为反向代理:

```nginx
# Nginx 配置示例
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:13000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 4. 配置 HTTPS

```bash
# 使用 Certbot 获取 SSL 证书
apt-get install certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

## 📦 更新应用

```bash
# 1. 备份数据库
docker exec mysql mysqldump -unav -plh116688257 nav > backup_before_update.sql

# 2. 拉取最新代码
git pull

# 3. 停止容器
docker compose down

# 4. 更新依赖
npm install

# 5. 更新数据库架构
export DATABASE_URL="mysql://nav:lh116688257@host.docker.internal:3306/nav"
npx prisma generate
npx prisma db push

# 6. 重新构建并启动
docker compose build --no-cache
docker compose up -d
```

## 🧹 完全卸载

```bash
# 1. 停止并删除容器
docker compose down -v

# 2. 删除镜像
docker rmi jg_nav:latest

# 3. 删除数据库 (可选)
docker exec mysql mysql -uroot -p -e "DROP DATABASE IF EXISTS nav;"

# 4. 删除项目文件
cd ..
rm -rf navigation
```

## 📞 技术支持

### 常见问题排查清单

- [ ] Docker 是否运行? `docker ps`
- [ ] MySQL 容器是否运行? `docker ps | grep mysql`
- [ ] 端口是否被占用? `netstat -tlnp | grep 13000`
- [ ] MySQL 用户是否有权限?
- [ ] 防火墙是否开放端口?
- [ ] 容器日志有无错误? `docker logs jg_nav`

### 获取帮助

如果遇到问题:
1. 查看应用日志: `docker logs jg_nav`
2. 查看 MySQL 日志: `docker logs mysql`
3. 检查容器网络: `docker network inspect bridge`
4. 验证数据库连接: `docker exec mysql mysql -unav -plh116688257 -e "SELECT 1"`

## 🎉 部署成功标志

当看到以下信息时,说明部署成功:

```
========================================
✓ 极光导航部署成功！
========================================
访问信息:
  本地访问: http://localhost:13000
  远程访问: http://your-ip:13000

容器信息:
  应用容器: jg_nav
  MySQL 容器: mysql
  镜像名称: jg_nav:latest
========================================
```

访问 http://localhost:13000 即可使用应用!
