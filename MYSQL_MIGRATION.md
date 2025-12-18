# MySQL 数据库迁移指南

本项目已从 SQLite 迁移到 MySQL 数据库。以下是详细的使用说明。

## 前提条件

1. **安装 MySQL**
   - 确保 MySQL 服务运行在本机 3306 端口
   - MySQL 版本建议 5.7+ 或 8.0+

2. **创建 MySQL 用户**

```sql
-- 登录 MySQL
mysql -u root -p

-- 创建用户和授权
CREATE USER 'nav'@'localhost' IDENTIFIED BY 'lh116688257';
CREATE USER 'nav'@'%' IDENTIFIED BY 'lh116688257';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'localhost';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
GRANT CREATE ON *.* TO 'nav'@'localhost';
GRANT CREATE ON *.* TO 'nav'@'%';
FLUSH PRIVILEGES;
```

## 方法一: 使用一键部署脚本 (推荐)

这是最简单的方法,会自动完成所有操作。

```bash
chmod +x deploy.sh
./deploy.sh
```

**脚本会自动:**
1. 检查 MySQL 连接
2. 创建 `nav` 数据库(如果不存在)
3. 使用 Prisma 创建表结构
4. 从 `prisma/dev.db` 迁移数据(如果存在)
5. 构建并启动 Docker 容器

## 方法二: 仅迁移数据库 (不启动容器)

如果只想迁移数据库而不启动容器:

```bash
chmod +x init-from-sqlite.sh
./init-from-sqlite.sh
```

**脚本会:**
1. 检查 SQLite 数据库 (`prisma/dev.db`)
2. 连接到 MySQL
3. 创建数据库和表结构
4. 导入所有数据
5. 验证数据完整性

## 方法三: 手动创建表结构

如果需要手动操作:

### 3.1 使用 SQL 文件

```bash
# 创建数据库和表
mysql -h localhost -u nav -plh116688257 < init-mysql-schema.sql

# 导入数据
npm install --save-dev sqlite3 mysql2
node migrate-to-mysql.js
```

### 3.2 使用 Prisma

```bash
# 设置环境变量
export DATABASE_URL="mysql://nav:lh116688257@localhost:3306/nav"

# 安装依赖
npm install

# 生成 Prisma Client 并创建表
npx prisma generate
npx prisma db push

# 导入数据
npm install --save-dev sqlite3 mysql2
node migrate-to-mysql.js
```

## 数据库配置说明

### 连接信息
- **主机**: localhost
- **端口**: 3306
- **用户名**: nav
- **密码**: lh116688257
- **数据库**: nav

### 连接字符串
```
mysql://nav:lh116688257@localhost:3306/nav
```

### Docker 容器连接
容器内使用 `host.docker.internal` 访问宿主机 MySQL:
```
mysql://nav:lh116688257@host.docker.internal:3306/nav
```

## 数据库表结构

迁移后会创建以下表:

| 表名 | 说明 |
|------|------|
| Site | 网站/链接数据 |
| Category | 分类数据 |
| User | 用户账户 |
| GlobalSettings | 全局设置 |
| Wallpaper | 壁纸数据 |
| CustomFont | 自定义字体 |
| Todo | 待办事项 |
| Countdown | 倒计时 |

## 验证迁移

迁移完成后,可以验证数据:

```bash
mysql -h localhost -u nav -plh116688257 -D nav -e "
SELECT 'Site' as TableName, COUNT(*) as Count FROM Site
UNION ALL SELECT 'Category', COUNT(*) FROM Category
UNION ALL SELECT 'User', COUNT(*) FROM User
UNION ALL SELECT 'GlobalSettings', COUNT(*) FROM GlobalSettings
UNION ALL SELECT 'Wallpaper', COUNT(*) FROM Wallpaper
UNION ALL SELECT 'CustomFont', COUNT(*) FROM CustomFont
UNION ALL SELECT 'Todo', COUNT(*) FROM Todo
UNION ALL SELECT 'Countdown', COUNT(*) FROM Countdown;
"
```

## 常见问题

### 1. MySQL 连接失败

**错误**: `MySQL 连接失败`

**解决**:
- 确保 MySQL 服务正在运行: `systemctl status mysql` (Linux) 或查看服务管理器 (Windows)
- 检查端口是否开放: `netstat -an | grep 3306`
- 验证用户权限: 重新执行创建用户的 SQL 语句

### 2. 权限不足

**错误**: `Access denied for user 'nav'`

**解决**:
```sql
-- 重新授权
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'localhost';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
FLUSH PRIVILEGES;
```

### 3. Docker 容器无法连接 MySQL

**错误**: 容器内连接失败

**解决**:
- Windows/Mac: 确保使用 `host.docker.internal`
- Linux: 使用主机 IP 或配置 `host.docker.internal`:
  ```yaml
  extra_hosts:
    - "host.docker.internal:host-gateway"
  ```

### 4. 数据迁移失败

**错误**: `数据迁移失败`

**解决**:
```bash
# 检查 SQLite 数据库是否存在
ls -la prisma/dev.db

# 手动运行迁移脚本查看详细错误
node migrate-to-mysql.js
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `deploy.sh` | 一键部署脚本(包含数据库初始化) |
| `init-from-sqlite.sh` | 独立的数据库迁移脚本 |
| `init-mysql-schema.sql` | MySQL 建表 SQL 文件 |
| `migrate-to-mysql.js` | SQLite 到 MySQL 数据迁移脚本 |
| `prisma/schema.prisma` | Prisma 数据库模型定义 |
| `docker-compose.yml` | Docker Compose 配置(MySQL 版本) |

## 修改数据库配置

如需修改数据库连接信息,请编辑以下文件:

1. **deploy.sh** - 部署脚本配置
```bash
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="nav"
MYSQL_PASSWORD="lh116688257"
MYSQL_DATABASE="nav"
```

2. **docker-compose.yml** - 容器环境变量
```yaml
environment:
  - DATABASE_URL=mysql://nav:lh116688257@host.docker.internal:3306/nav
```

3. **migrate-to-mysql.js** - 迁移脚本配置
```javascript
const MYSQL_CONFIG = {
  host: 'localhost',
  port: 3306,
  user: 'nav',
  password: 'lh116688257',
  database: 'nav'
};
```

## 启动应用

数据库迁移完成后,启动应用:

```bash
# 使用部署脚本(推荐)
./deploy.sh

# 或手动启动
docker-compose up -d

# 查看日志
docker logs -f jg_nav
```

访问地址: http://localhost:2266
