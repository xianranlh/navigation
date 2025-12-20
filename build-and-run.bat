@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 极光导航 - Docker 一键构建和启动脚本
REM 适用于 Windows 系统

echo ==========================================
echo   极光导航 - Docker 一键部署脚本
echo ==========================================
echo.

REM 检查 Docker 是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Docker，请先安装 Docker Desktop
    pause
    exit /b 1
)

REM 检查 Docker 是否运行
docker ps >nul 2>&1
if errorlevel 1 (
    echo [错误] Docker 未运行，请先启动 Docker Desktop
    pause
    exit /b 1
)

REM 检查 Docker Compose 是否可用
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose --version >nul 2>&1
    if errorlevel 1 (
        echo [错误] 未检测到 Docker Compose，请先安装 Docker Compose
        pause
        exit /b 1
    )
    set COMPOSE_CMD=docker-compose
) else (
    set COMPOSE_CMD=docker compose
)

echo [步骤 1/4] 停止并删除旧容器...
%COMPOSE_CMD% down >nul 2>&1
echo √ 完成
echo.

echo [步骤 2/4] 构建 Docker 镜像...
echo 这可能需要几分钟时间，请耐心等待...
%COMPOSE_CMD% build --no-cache
if errorlevel 1 (
    echo [错误] 镜像构建失败
    pause
    exit /b 1
)
echo √ 镜像构建完成
echo.

echo [步骤 3/4] 启动容器...
%COMPOSE_CMD% up -d
if errorlevel 1 (
    echo [错误] 容器启动失败
    pause
    exit /b 1
)
echo √ 容器启动成功
echo.

echo [步骤 4/4] 检查容器状态...
timeout /t 3 /nobreak >nul
%COMPOSE_CMD% ps
echo.

REM 检查容器是否运行
docker ps --filter "name=jg_nav" --format "{{.Names}}" | findstr "jg_nav" >nul
if errorlevel 1 (
    echo ==========================================
    echo   部署失败，请查看错误日志
    echo ==========================================
    echo.
    echo 查看日志命令: %COMPOSE_CMD% logs
    pause
    exit /b 1
) else (
    echo ==========================================
    echo   部署成功！
    echo ==========================================
    echo.
    echo 访问地址: http://localhost:12266
    echo.
    echo 常用命令:
    echo   查看日志: %COMPOSE_CMD% logs -f
    echo   停止服务: %COMPOSE_CMD% stop
    echo   启动服务: %COMPOSE_CMD% start
    echo   重启服务: %COMPOSE_CMD% restart
    echo   删除服务: %COMPOSE_CMD% down
    echo.
)

pause
