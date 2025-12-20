# 问题排查和解决方案

## 当前问题

1. ❌ 容器仍显示"数据库不存在，正在初始化..." - 说明使用的是旧镜像
2. ❌ DNS 错误：`ENOTFOUND server.66993399.com` - 无法解析域名

## 快速解决步骤

### 步骤 1：运行诊断脚本（了解当前状态）

```bash
chmod +x diagnose.sh
./diagnose.sh
```

这会显示：
- 容器状态和环境变量
- MySQL 连接情况
- 网络配置
- 最新日志

### 步骤 2：强制重建（推荐）

```bash
chmod +x force-rebuild.sh
./force-rebuild.sh
```

这个脚本会：
- ✅ 完全删除旧容器和镜像
- ✅ 重新构建最新镜像（包含修复的 entrypoint.sh）
- ✅ 初始化 MySQL 数据库
- ✅ 启动新容器
- ✅ 显示启动日志

### 步骤 3：查看日志验证

```bash
docker-compose logs -f nav
```

**预期看到：**
```
DEBUG: DATABASE_URL = mysql://nav:lh116688257@127.0.0.1:3306/nav
使用 MySQL 数据库
MySQL 连接: mysql://nav:lh116688257@127.0.0.1:3306/nav
✓ Ready in XXms
```

**不应该看到：**
```
数据库不存在，正在初始化...
数据库初始化完成
```

## DNS 错误处理

### 关于 `server.66993399.com` 错误

这个错误可能来自：

1. **Bing 壁纸 API 或其他外部服务**
   - 这可能是一个失效的域名
   - 检查代码中的壁纸获取逻辑

2. **暂时忽略（如果不影响主要功能）**
   - 如果应用的其他功能正常，这个 DNS 错误可能只影响某个特定功能

### 查找域名引用

```bash
# 搜索可能的配置文件
grep -r "66993399" . --include="*.js" --include="*.ts" --include="*.json" --include="*.env*"

# 检查环境变量
docker exec nav env
```

### 如果需要，添加 hosts 映射

如果这个域名是必需的，可以在 `/etc/hosts` 中添加映射，或在 docker-compose.yml 中添加：

```yaml
extra_hosts:
  - "server.66993399.com:127.0.0.1"
```

## 验证 MySQL 连接

### 从容器内测试

```bash
# 检查环境变量
docker exec nav env | grep DATABASE_URL

# 测试 MySQL 连接（如果有 mysql 客户端）
docker exec nav sh -c 'apt-get update && apt-get install -y default-mysql-client && mysql -h 127.0.0.1 -u nav -plh116688257 nav -e "SHOW TABLES;"'
```

### 从 MySQL 容器验证

```bash
# 验证数据库存在
docker exec -i mysql mysql -u root -plh116688257 -e "SHOW DATABASES LIKE 'nav';"

# 验证用户权限
docker exec -i mysql mysql -u root -plh116688257 -e "SHOW GRANTS FOR 'nav'@'%';"

# 验证表结构
docker exec -i mysql mysql -u nav -plh116688257 nav -e "SHOW TABLES;"
```

## 常见问题

### Q1: 日志仍显示 SQLite 初始化消息？
**A:** 说明容器使用的是旧镜像。运行 `./force-rebuild.sh` 强制重建。

### Q2: 无法连接到 MySQL？
**A:** 检查：
1. MySQL 容器是否运行：`docker ps | grep mysql`
2. 端口是否正确：`netstat -tlnp | grep 3306`
3. 防火墙设置

### Q3: host 网络模式下端口冲突？
**A:** 如果 3000 端口已被占用，需要：
1. 停止占用 3000 端口的进程
2. 或修改应用配置使用其他端口（通过环境变量 PORT）

## 完整的手动重建步骤

如果脚本无法运行，手动执行：

```bash
# 1. 停止并删除
docker-compose down
docker rm -f nav
docker rmi nav:latest

# 2. 确保 MySQL 数据库存在
docker exec -i mysql mysql -u root -plh116688257 -e "CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257'; GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%'; FLUSH PRIVILEGES;"

# 3. 创建表（如果需要）
docker exec -i mysql mysql -u root -plh116688257 nav < init-mysql-tables.sql

# 4. 重建镜像
docker-compose build --no-cache

# 5. 启动
docker-compose up -d

# 6. 查看日志
docker-compose logs -f nav
```

## 成功标志

✅ 日志显示 MySQL 连接字符串
✅ 没有 SQLite 初始化消息
✅ 应用成功启动
✅ 可以通过 http://服务器IP:3000 访问
✅ 数据可以正常存储和读取
