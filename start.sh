#!/bin/bash

# 星穹导航 - 一键部署脚本
# 使用方法: chmod +x start.sh && ./start.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║       🚀 星穹导航 - 一键部署          ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装，请先安装 Docker${NC}"
    echo "安装命令: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose 未安装${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker 已安装${NC}"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# MySQL 连接信息
MYSQL_HOST="${MYSQL_HOST:-host.docker.internal}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-nav}"
MYSQL_PASS="${MYSQL_PASS:-lh116688257}"
MYSQL_DB="${MYSQL_DB:-nav}"

echo -e "${YELLOW}📦 构建 Docker 镜像...${NC}"
docker compose build --no-cache

echo -e "${YELLOW}🚀 启动容器...${NC}"
docker compose up -d

echo -e "${YELLOW}⏳ 等待服务启动 (15秒)...${NC}"
sleep 15

# 初始化数据库
echo -e "${YELLOW}🗄️ 同步数据库结构...${NC}"
docker compose exec -T backend npx prisma db push --accept-data-loss 2>/dev/null || {
    echo -e "${YELLOW}⏳ 后端服务启动中，再等待 10 秒...${NC}"
    sleep 10
    docker compose exec -T backend npx prisma db push --accept-data-loss
}

# 询问是否填充示例数据
read -p "是否填充示例数据? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}📝 填充示例数据...${NC}"
    docker compose exec -T backend node prisma/seed.js 2>/dev/null || echo -e "${YELLOW}示例数据可能已存在${NC}"
fi

# 获取服务器 IP
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✅ 部署成功！                 ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "🌐 前端地址: ${CYAN}http://${SERVER_IP}:13000${NC}"
echo -e "🔧 后端 API: ${CYAN}http://${SERVER_IP}:13001/api/v1${NC}"
echo ""
echo -e "${YELLOW}常用命令:${NC}"
echo "  查看日志: docker compose logs -f"
echo "  停止服务: docker compose down"
echo "  重启服务: docker compose restart"
echo ""
