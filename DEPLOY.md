# Debian 12 VPS 部署指南

## 前置条件

确保您的 VPS 上已有 MySQL 容器运行在 3306 端口。

---

## 一、安装 Docker

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装依赖
sudo apt install -y ca-certificates curl gnupg

# 添加 Docker GPG 密钥
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 添加 Docker 仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动并设置开机自启
sudo systemctl enable docker
sudo systemctl start docker

# 将当前用户加入 docker 组（可选，免 sudo）
sudo usermod -aG docker $USER
newgrp docker
```

---

## 二、准备 MySQL 数据库

```bash
# 连接已有的 MySQL 容器创建数据库和用户
docker exec -it <mysql容器名> mysql -uroot -plh116688257 -e "
CREATE DATABASE IF NOT EXISTS nav CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'nav'@'%' IDENTIFIED BY 'lh116688257';
GRANT ALL PRIVILEGES ON nav.* TO 'nav'@'%';
FLUSH PRIVILEGES;
"
```

---

## 三、上传项目代码

**方式一：Git 克隆**
```bash
cd /opt
git clone <your-repo-url> navigation
cd navigation
```

**方式二：SCP 上传**
```bash
# 在本地执行
scp -r ./navigation root@<VPS-IP>:/opt/
```

---

## 四、修改配置

```bash
cd /opt/navigation

# 编辑后端环境变量（如需调整 MySQL 连接）
nano backend/.env
```

确认 `DATABASE_URL` 中的主机名：
- 如果 MySQL 在宿主机：使用 `host.docker.internal`
- 如果 MySQL 在同一 Docker 网络：使用容器名

---

## 五、构建并启动容器

```bash
cd /opt/navigation

# 构建镜像
docker compose build

# 启动容器（后台运行）
docker compose up -d

# 查看容器状态
docker compose ps

# 查看日志
docker compose logs -f
```

---

## 六、初始化数据库

```bash
# 进入后端容器执行数据库迁移
docker compose exec backend npx prisma db push

# 填充示例数据（可选）
docker compose exec backend node prisma/seed.js
```

---

## 七、验证部署

```bash
# 检查服务是否正常
curl http://localhost:13001/health    # 后端健康检查
curl http://localhost:13000           # 前端页面
```

浏览器访问：`http://<VPS-IP>:13000`

---

## 八、常用命令

```bash
# 重启服务
docker compose restart

# 停止服务
docker compose down

# 查看日志
docker compose logs -f backend
docker compose logs -f frontend

# 重新构建并启动
docker compose up -d --build

# 进入容器调试
docker compose exec backend sh
docker compose exec frontend sh
```

---

## 九、配置反向代理（可选）

如需通过域名访问，可安装 Nginx：

```bash
sudo apt install -y nginx

# 创建站点配置
sudo nano /etc/nginx/sites-available/navigation
```

配置内容：
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:13000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://127.0.0.1:13001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

启用配置：
```bash
sudo ln -s /etc/nginx/sites-available/navigation /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 故障排查

| 问题 | 解决方案 |
|------|----------|
| 数据库连接失败 | 检查 `DATABASE_URL`，确认 MySQL 容器网络可达 |
| 端口被占用 | `sudo lsof -i :13000` 查看占用进程 |
| 容器启动失败 | `docker compose logs backend` 查看错误日志 |
