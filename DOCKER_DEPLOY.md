# Docker 一键部署脚本使用说明

本项目提供了跨平台的一键构建和部署脚本，支持 Linux、Mac 和 Windows 系统。

## 🚀 快速开始

### Windows 系统

#### 方式一：使用批处理脚本（推荐）
双击运行 `build-and-run.bat` 文件，或在命令提示符中执行：
```cmd
build-and-run.bat
```

#### 方式二：使用 PowerShell 脚本
右键点击 `build-and-run.ps1`，选择"使用 PowerShell 运行"，或在 PowerShell 中执行：
```powershell
.\build-and-run.ps1
```

> **注意**: 如果遇到执行策略限制，请以管理员身份运行 PowerShell 并执行：
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

### Linux / Mac 系统

1. 给脚本添加执行权限：
```bash
chmod +x build-and-run.sh
```

2. 运行脚本：
```bash
./build-and-run.sh
```

## 📋 脚本功能

这些脚本会自动完成以下步骤：

1. ✅ 检查 Docker 和 Docker Compose 是否安装
2. 🗑️ 停止并删除旧容器（如果存在）
3. 🔨 构建最新的 Docker 镜像
4. 🚀 启动容器
5. ✔️ 验证容器运行状态

## 🌐 访问应用

部署成功后，在浏览器中访问：
```
http://localhost:12266
```

## 🛠️ 常用 Docker Compose 命令

```bash
# 查看实时日志
docker compose logs -f

# 停止服务
docker compose stop

# 启动服务
docker compose start

# 重启服务
docker compose restart

# 停止并删除容器
docker compose down

# 查看容器状态
docker compose ps
```

## ⚠️ 前置要求

- **Docker**: 确保已安装 Docker Engine 或 Docker Desktop
- **Docker Compose**: 确保已安装 Docker Compose（Docker Desktop 已包含）

### 检查安装

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker compose version
```

## 🔧 故障排查

### Docker 未运行
确保 Docker 服务已启动：
- **Windows/Mac**: 启动 Docker Desktop
- **Linux**: `sudo systemctl start docker`

### 端口被占用
如果端口 12266 被占用，可以修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - "你的端口:3000"  # 例如 "8080:3000"
```

### 构建失败
尝试清理 Docker 缓存后重新构建：
```bash
docker system prune -a
```

### 查看详细日志
```bash
docker compose logs nav
```

## 📝 手动部署

如果不使用一键脚本，也可以手动执行：

```bash
# 停止旧容器
docker compose down

# 构建镜像
docker compose build --no-cache

# 启动容器
docker compose up -d

# 查看日志
docker compose logs -f
```

## 🎯 数据持久化

容器使用 Docker Volume 存储数据，位于：
- Volume 名称: `navigation_data`
- 容器内路径: `/app/data`

数据会在容器重启后保留。如需备份数据：
```bash
docker cp jg_nav:/app/data/dev.db ./backup/
```

## 🆘 获取帮助

如遇问题，请查看：
1. 容器日志: `docker compose logs -f`
2. Docker 状态: `docker compose ps`
3. 系统资源: 确保有足够的磁盘空间和内存

---

**项目**: 极光导航
**版本**: 0.1.0
**License**: 请查看 LICENSE 文件
