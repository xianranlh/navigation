# 极光导航 - Debian 12 一键安装指南

## 功能说明

这个一键脚本 `debian12-install.sh` 将自动完成以下所有操作:

1. ✅ 检查系统版本 (Debian 12)
2. ✅ 更新系统软件包
3. ✅ 安装 Docker 和 Docker Compose
4. ✅ 安装 MySQL Server
5. ✅ 配置 MySQL 数据库和用户
6. ✅ 安装 Node.js 18.x LTS
7. ✅ 安装项目依赖
8. ✅ 初始化数据库 (使用 Prisma)
9. ✅ 迁移 SQLite 数据 (如果存在)
10. ✅ 构建 Docker 镜像
11. ✅ 启动容器
12. ✅ 配置防火墙

## 使用方法

### 方式一: 直接运行 (推荐)

```bash
# 1. 切换到 root 用户
sudo su

# 2. 进入项目目录
cd /path/to/navigation

# 3. 运行一键安装脚本
bash debian12-install.sh
```

### 方式二: 使用 curl 远程安装

如果脚本已上传到服务器或 Git 仓库:

```bash
# 使用 curl 下载并运行
curl -fsSL https://your-domain.com/debian12-install.sh | sudo bash
```

## 系统要求

- 操作系统: Debian 12 (Bookworm)
- 架构: x86_64 / amd64
- 内存: 至少 1GB RAM
- 磁盘: 至少 5GB 可用空间
- 权限: Root 或 sudo 权限

## 默认配置

### 应用配置
- 应用端口: `2266`
- 容器名称: `jg_nav`
- 镜像名称: `jg_nav:latest`

### MySQL 配置
- 数据库: `nav`
- 用户: `nav`
- 密码: `lh116688257`
- Root 密码: `root123456`
- 端口: `3306`

## 安装后访问

### 本地访问
```
http://localhost:2266
```

### 远程访问
```
http://your-server-ip:2266
```

## 常用管理命令

### 查看容器日志
```bash
docker logs -f jg_nav
```

### 停止服务
```bash
cd /path/to/navigation
docker compose down
```

### 启动服务
```bash
cd /path/to/navigation
docker compose up -d
```

### 重启服务
```bash
cd /path/to/navigation
docker compose restart
```

### 查看容器状态
```bash
docker ps | grep jg_nav
```

### 进入容器内部
```bash
docker exec -it jg_nav sh
```

## MySQL 管理

### 连接到 MySQL
```bash
mysql -uroot -proot123456
```

### 查看数据库
```bash
mysql -uroot -proot123456 -e "SHOW DATABASES;"
```

### 备份数据库
```bash
mysqldump -unav -plh116688257 nav > nav_backup_$(date +%Y%m%d).sql
```

### 恢复数据库
```bash
mysql -unav -plh116688257 nav < nav_backup_20231219.sql
```

## 故障排查

### 1. 检查 Docker 服务状态
```bash
systemctl status docker
```

### 2. 检查 MySQL 服务状态
```bash
systemctl status mysql
```

### 3. 查看容器日志
```bash
docker logs jg_nav --tail 100
```

### 4. 测试 MySQL 连接
```bash
mysql -h localhost -P 3306 -unav -plh116688257 -e "SELECT 1"
```

### 5. 检查端口占用
```bash
netstat -tlnp | grep 2266
```

### 6. 重新构建容器
```bash
cd /path/to/navigation
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## 卸载

如果需要完全卸载:

```bash
# 1. 停止并删除容器
cd /path/to/navigation
docker compose down -v

# 2. 删除镜像
docker rmi jg_nav:latest

# 3. 删除 MySQL 数据库 (可选)
mysql -uroot -proot123456 -e "DROP DATABASE IF EXISTS nav;"
mysql -uroot -proot123456 -e "DROP USER IF EXISTS 'nav'@'localhost';"
mysql -uroot -proot123456 -e "DROP USER IF EXISTS 'nav'@'%';"

# 4. 卸载 Docker (可选)
apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
apt-get autoremove -y

# 5. 卸载 MySQL (可选)
apt-get remove -y mysql-server mysql-client
apt-get autoremove -y

# 6. 删除项目文件 (可选)
rm -rf /path/to/navigation
```

## 安全建议

1. **修改默认密码**: 安装完成后,建议修改 MySQL 密码
   ```bash
   mysql -uroot -proot123456
   ALTER USER 'nav'@'localhost' IDENTIFIED BY 'new_password';
   ALTER USER 'nav'@'%' IDENTIFIED BY 'new_password';
   FLUSH PRIVILEGES;
   ```

2. **配置防火墙**: 限制外部访问
   ```bash
   # 只允许特定 IP 访问
   ufw allow from 192.168.1.100 to any port 2266
   ```

3. **使用 HTTPS**: 配置反向代理 (Nginx/Caddy)

4. **定期备份**: 设置定时任务备份数据库

## 更新应用

```bash
# 1. 拉取最新代码
cd /path/to/navigation
git pull

# 2. 停止容器
docker compose down

# 3. 更新依赖
npm install

# 4. 更新数据库
npx prisma generate
npx prisma db push

# 5. 重新构建并启动
docker compose build --no-cache
docker compose up -d
```

## 技术支持

如果遇到问题,请:
1. 查看容器日志: `docker logs jg_nav`
2. 检查系统日志: `journalctl -u docker`
3. 确认端口未被占用: `netstat -tlnp | grep 2266`

## 注意事项

- 首次运行需要下载大量软件包,请保持网络畅通
- 安装过程约需 5-10 分钟,具体取决于网络速度
- 脚本会自动检测并跳过已安装的软件
- 支持重复运行,不会重复安装已存在的组件
- 如果 SQLite 数据库存在,会自动迁移到 MySQL
