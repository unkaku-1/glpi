# GLPI 项目部署指南 (Docker-Compose)

本指南将引导你使用 `docker-compose` 在本地环境中快速部署 GLPI 项目。这是官方推荐的用于本地开发和测试的方法，可以极大地简化环境配置和依赖管理。

## 1. 先决条件

在开始之前，请确保你的系统已安装以下软件：

- **Git:** 用于克隆项目代码仓库。
- **Docker 和 Docker Compose:** 用于构建和管理容器化应用。请确保 Docker Desktop 正在运行，并已切换到 Linux 容器模式。
- **稳定的网络连接:** 部署过程中需要从网络上下载 Docker 镜像，不稳定的网络可能导致失败。

## 2. 部署步骤

### 第 1 步：克隆项目

首先，从 GitHub 克隆 GLPI 的官方代码仓库。

```bash
git clone https://github.com/glpi-project/glpi.git
```

### 第 2 步：配置 Docker 镜像加速 (关键)

直接从 Docker Hub 拉取镜像在中国大陆地区可能速度很慢或因网络问题失败（如我们之前遇到的 `EOF` 或 `TLS handshake failure` 错误）。强烈建议配置一个国内的镜像加速器。

**操作方法 (Windows/Mac Docker Desktop):**

1.  打开 Docker Desktop。
2.  进入 **Settings** (设置) > **Docker Engine** (Docker 引擎)。
3.  在右侧的 JSON 配置窗口中，添加或修改 `registry-mirrors` 键值对。这里我们使用**网易的镜像源**，因为它在之前的尝试中成功了：

    ```json
    {
      "registry-mirrors": [
        "http://hub-mirror.c.163.com"
      ]
    }
    ```

4.  点击 **Apply & Restart** (应用并重启) 按钮，等待 Docker 服务重启。

> **注意:** 此操作会修改你全局的 Docker 配置，对所有项目生效。

### 第 3 步：启动 GLPI 服务

进入克隆好的 `glpi` 目录，并执行 `docker-compose` 命令来构建并启动所有服务。

```bash
cd glpi
docker-compose up -d --build
```

- `--build`: 表示需要根据 `Dockerfile` 构建 `app` 服务的镜像。
- `-d`: 表示在后台（detached mode）运行容器。

### 第 4 步：更新应用程序依赖

首次启动后，GLPI 的 Web 界面可能会提示 "Application dependencies are not up to date"。这是因为项目的 PHP 和 NPM 依赖需要被安装。

在 `glpi` 目录下，执行以下命令来进入 `app` 容器内部并安装依赖：

```bash
docker-compose exec -T app php bin/console dependencies install
```

这个过程会花费几分钟时间，因为它需要下载 Composer 和 NPM 的所有包，并进行编译。

### 第 5 步：访问 GLPI

当所有步骤���成后，GLPI 应用及其关联服务就可以通过以下地址访问了：

- **GLPI 应用主界面:** [http://localhost:8080](http://localhost:8080)
- **Mailpit (邮件捕获/调试工具):** [http://localhost:8025](http://localhost:8025)
- **DBGate (数据库管理工具):** [http://localhost:8090](http://localhost:8090)

## 3. 故障排查

- **镜像拉取失败:** 如果在第 3 步遇到任何网络相关的错误，请返回第 2 步，确认镜像加速器是否配置正确并已生效，或尝试更换其他镜像源（如阿里云、腾讯云等）。
- **Git 仓库所有权问题:** 在执行依赖安装时，你可能会在日志中看到 `fatal: detected dubious ownership in repository at '/var/www/glpi'` 的警告。这通常发生在 Docker 容器内，因为容器内的用户与宿主机用户不匹配。对于本地开发环境，这通常是无害的，可以忽略。

部署完成！现在你可以开始使用 GLPI 了。
