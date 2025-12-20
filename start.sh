#!/bin/bash

# 星穹导航 - 一键部署脚本
# 使用方法: chmod +x start.sh && ./start.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

printf "${CYAN}"
printf "╔═══════════════════════════════════════╗\n"
printf "║       🚀 星穹导航 - 一键部署          ║\n"
printf "╚═══════════════════════════════════════╝\n"
printf "${NC}\n"

# 检查 Docker
if ! which docker > /dev/null 2>&1; then
    printf "${RED}❌ Docker 未安装，请先安装 Docker${NC}\n"
    printf "安装命令: curl -fsSL https://get.docker.com | sh\n"
    exit 1
fi

# 检查 docker compose
if ! docker compose version > /dev/null 2>&1; then
    printf "${RED}❌ Docker Compose 未安装${NC}\n"
    exit 1
fi

printf "${GREEN}✓ Docker 已安装${NC}\n"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

printf "${YELLOW}📦 构建 Docker 镜像...${NC}\n"
docker compose build --no-cache

printf "${YELLOW}🚀 启动容器...${NC}\n"
docker compose up -d

printf "${YELLOW}⏳ 等待服务启动 (15秒)...${NC}\n"
sleep 15

# 初始化数据库
printf "${YELLOW}🗄️ 同步数据库结构...${NC}\n"
docker compose exec -T backend npx prisma db push --accept-data-loss 2>/dev/null || {
    printf "${YELLOW}⏳ 后端服务启动中，再等待 10 秒...${NC}\n"
    sleep 10
    docker compose exec -T backend npx prisma db push --accept-data-loss
}

# 询问是否填充示例数据
printf "是否填充示例数据? (y/n): "
read -r REPLY
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    printf "${YELLOW}📝 填充示例数据...${NC}\n"
    docker compose exec -T backend node prisma/seed.js 2>/dev/null || printf "${YELLOW}示例数据可能已存在${NC}\n"
fi

# 获取服务器 IP
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="localhost"
fi

printf "\n"
printf "${GREEN}╔═══════════════════════════════════════╗${NC}\n"
printf "${GREEN}║         ✅ 部署成功！                 ║${NC}\n"
printf "${GREEN}╚═══════════════════════════════════════╝${NC}\n"
printf "\n"
printf "🌐 前端地址: ${CYAN}http://${SERVER_IP}:13000${NC}\n"
printf "🔧 后端 API: ${CYAN}http://${SERVER_IP}:13001/api/v1${NC}\n"
printf "\n"
printf "${YELLOW}常用命令:${NC}\n"
printf "  查看日志: docker compose logs -f\n"
printf "  停止服务: docker compose down\n"
printf "  重启服务: docker compose restart\n"
printf "\n"
