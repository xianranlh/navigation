# 极光导航 - Docker 一键构建和启动脚本
# 适用于 Windows PowerShell

# 设置编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  极光导航 - Docker 一键部署脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Docker 是否安装
try {
    $null = docker --version
} catch {
    Write-Host "[错误] 未检测到 Docker，请先安装 Docker Desktop" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 检查 Docker 是否运行
try {
    $null = docker ps 2>&1
} catch {
    Write-Host "[错误] Docker 未运行，请先启动 Docker Desktop" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 检查 Docker Compose 是否可用
$composeCmd = "docker compose"
try {
    $null = docker compose version 2>&1
} catch {
    try {
        $null = docker-compose --version 2>&1
        $composeCmd = "docker-compose"
    } catch {
        Write-Host "[错误] 未检测到 Docker Compose，请先安装 Docker Compose" -ForegroundColor Red
        Read-Host "按回车键退出"
        exit 1
    }
}

Write-Host "[步骤 1/4] 停止并删除旧容器..." -ForegroundColor Yellow
try {
    if ($composeCmd -eq "docker compose") {
        docker compose down 2>$null
    } else {
        docker-compose down 2>$null
    }
} catch {
    # 忽略错误，继续执行
}
Write-Host "√ 完成" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 2/4] 构建 Docker 镜像..." -ForegroundColor Yellow
Write-Host "这可能需要几分钟时间，请耐心等待..."
try {
    if ($composeCmd -eq "docker compose") {
        docker compose build --no-cache
    } else {
        docker-compose build --no-cache
    }
    if ($LASTEXITCODE -ne 0) {
        throw "构建失败"
    }
} catch {
    Write-Host "[错误] 镜像构建失败" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}
Write-Host "√ 镜像构建完成" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 3/4] 启动容器..." -ForegroundColor Yellow
try {
    if ($composeCmd -eq "docker compose") {
        docker compose up -d
    } else {
        docker-compose up -d
    }
    if ($LASTEXITCODE -ne 0) {
        throw "启动失败"
    }
} catch {
    Write-Host "[错误] 容器启动失败" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}
Write-Host "√ 容器启动成功" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 4/4] 检查容器状态..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
if ($composeCmd -eq "docker compose") {
    docker compose ps
} else {
    docker-compose ps
}
Write-Host ""

# 检查容器是否运行
$containerRunning = docker ps --filter "name=jg_nav" --format "{{.Names}}" | Select-String "jg_nav"

if ($containerRunning) {
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "  部署成功！" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "访问地址: " -NoNewline
    Write-Host "http://localhost:12266" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "常用命令:"
    Write-Host "  查看日志: $composeCmd logs -f"
    Write-Host "  停止服务: $composeCmd stop"
    Write-Host "  启动服务: $composeCmd start"
    Write-Host "  重启服务: $composeCmd restart"
    Write-Host "  删除服务: $composeCmd down"
    Write-Host ""
} else {
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host "  部署失败，请查看错误日志" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "查看日志命令: $composeCmd logs"
    Read-Host "按回车键退出"
    exit 1
}

Read-Host "按回车键退出"
