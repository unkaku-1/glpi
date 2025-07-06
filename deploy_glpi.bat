@echo off
setlocal

:: ============================================================================
:: GLPI 一键部署脚本 (Windows)
::
:: 功能:
:: 1. 检查 Git 和 Docker 是否已安装。
:: 2. 克隆 GLPI 项目仓库。
:: 3. 启动 Docker Compose 服务。
:: 4. 安装应用依赖。
:: ============================================================================

echo.
echo =================================
echo      GLPI 一键部署脚本
echo =================================
echo.

:: 检查 Git 是否安装
echo 正在检查 Git...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未找到 Git。请先安装 Git 并确保其在系统的 PATH 环境变量中。
    goto :eof
)
echo Git 已安装。

:: 检查 Docker 是否安装
echo 正在检查 Docker...
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未找到 Docker。请先安装 Docker Desktop。
    goto :eof
)
echo Docker 已安装。

:: 检查 Docker 是否正在运行
echo 正在检查 Docker 服务状态...
docker info >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: Docker Desktop 未在运行或未响应。
    echo 请先启动 Docker Desktop，并确保它已切���到 Linux 容器模式。
    goto :eof
)
echo Docker 服务正在运行。

:: 步骤 1: 克隆项目
if not exist "glpi" (
    echo.
    echo --- 步骤 1: 克隆 GLPI 项目仓库 ---
    git clone https://github.com/glpi-project/glpi.git
    if %errorlevel% neq 0 (
        echo 错误: 克隆 GLPI 项目失败。请检查网络连接或 Git 配置。
        goto :eof
    )
) else (
    echo GLPI 目录已存在，跳过克隆步骤。
)

cd glpi

:: 步骤 2: 启动 Docker 服务
echo.
echo --- 步骤 2: 使用 Docker Compose 启动服务 ---
echo 这可能需要一些时间，特别是首次构建时...
docker-compose up -d --build
if %errorlevel% neq 0 (
    echo 错误: docker-compose 启动失败。
    echo 请检查 Docker 配置和网络连接。建议配置 Docker 镜像加速器。
    echo 详细信息请参考 DEPLOYMENT_GUIDE_CN.md
    goto :eof
)
echo Docker 服务已成功启动。

:: 步骤 3: 安装应用依赖
echo.
echo --- 步骤 3: 安装应用程序依赖 ---
echo 正在安装 Composer 和 NPM 包，这可能需要几分钟...
docker-compose exec -T app php bin/console dependencies install
if %errorlevel% neq 0 (
    echo 错误: 依赖安装失败。
    goto :eof
)
echo 依赖已成功安装。

echo.
echo ==================================================
echo          部署��功!
echo ==================================================
echo.
echo 你现在可以通过以下地址访问 GLPI:
echo.
echo   - GLPI 应用: http://localhost:8080
echo   - 邮件调试 (Mailpit): http://localhost:8025
echo   - 数据库管理 (DBGate): http://localhost:8090
echo.
echo 详细信息请参考 DEPLOYMENT_GUIDE_CN.md 和 USAGE_GUIDE_CN.md
echo.

endlocal
pause
