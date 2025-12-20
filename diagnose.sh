#!/bin/bash

echo "========================================="
echo "Nav 应用诊断信息"
echo "========================================="
echo ""

echo "1. 容器状态："
echo "---"
docker-compose ps
echo ""

echo "2. 容器环境变量："
echo "---"
docker exec nav env | grep -E "(DATABASE_URL|NODE_ENV|PORT)" || echo "容器未运行"
echo ""

echo "3. 容器内 DATABASE_URL 测试："
echo "---"
docker exec nav sh -c 'echo "DATABASE_URL = $DATABASE_URL"' || echo "容器未运行"
echo ""

echo "4. MySQL 连接测试（从主机）："
echo "---"
docker exec -i mysql mysql -u nav -plh116688257 -e "SELECT 'MySQL 连接成功' as status;" 2>&1 | grep -v "Using a password"
echo ""

echo "5. MySQL 数据库和表："
echo "---"
docker exec -i mysql mysql -u nav -plh116688257 -e "USE nav; SHOW TABLES;" 2>&1 | grep -v "Using a password"
echo ""

echo "6. 容器网络模式："
echo "---"
docker inspect nav --format '{{.HostConfig.NetworkMode}}' 2>/dev/null || echo "容器未运行"
echo ""

echo "7. 最近的容器日志（20行）："
echo "---"
docker-compose logs --tail=20 nav
echo ""

echo "8. 主机网络信息："
echo "---"
echo "主机 IP: $(hostname -I | awk '{print $1}')"
echo "Hostname: $(hostname)"
echo ""

echo "9. DNS 测试："
echo "---"
echo "测试是否能解析 server.66993399.com..."
nslookup server.66993399.com 2>&1 || echo "无法解析此域名"
echo ""

echo "10. 检查镜像构建时间："
echo "---"
docker images nav:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}"
echo ""

echo "========================================="
echo "诊断完成"
echo "========================================="
