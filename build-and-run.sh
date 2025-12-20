#!/bin/bash

# 极光导航 - Docker 一键构建和启动脚本
# 适用于 Linux/Mac 系统

set -e

echo "=========================================="
echo "  极光导航 - Docker 一键部署脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未检测到 Docker，请先安装 Docker${NC}"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}错误: 未检测到 Docker Compose，请先安装 Docker Compose${NC}"
    exit 1
fi

# 使用 docker compose 或 docker-compose
COMPOSE_CMD="docker compose"
if ! docker compose version &> /dev/null; then
    COMPOSE_CMD="docker-compose"
fi

echo -e "${YELLOW}步骤 1/4: 停止并删除旧容器...${NC}"
$COMPOSE_CMD down 2>/dev/null || true
echo -e "${GREEN}✓ 完成${NC}"
echo ""

echo -e "${YELLOW}步骤 2/4: 构建 Docker 镜像...${NC}"
echo "这可能需要几分钟时间，请耐心等待..."
$COMPOSE_CMD build --no-cache
echo -e "${GREEN}✓ 镜像构建完成${NC}"
echo ""

echo -e "${YELLOW}步骤 3/4: 启动容器...${NC}"
$COMPOSE_CMD up -d
echo -e "${GREEN}✓ 容器启动成功${NC}"
echo ""

echo -e "${YELLOW}步骤 4/4: 检查容器状态...${NC}"
sleep 3
$COMPOSE_CMD ps
echo ""

# 检查容器是否正在运行
if [ "$($COMPOSE_CMD ps -q nav)" ]; then
    echo -e "${GREEN}=========================================="
    echo "  部署成功！"
    echo "==========================================${NC}"
    echo ""
    echo -e "${GREEN}访问地址:${NC} http://localhost:12266"
    echo ""
    echo "常用命令:"
    echo "  查看日志: $COMPOSE_CMD logs -f"
    echo "  停止服务: $COMPOSE_CMD stop"
    echo "  启动服务: $COMPOSE_CMD start"
    echo "  重启服务: $COMPOSE_CMD restart"
    echo "  删除服务: $COMPOSE_CMD down"
    echo ""
else
    echo -e "${RED}=========================================="
    echo "  部署失败，请查看错误日志"
    echo "==========================================${NC}"
    echo ""
    echo "查看日志命令: $COMPOSE_CMD logs"
    exit 1
fi
