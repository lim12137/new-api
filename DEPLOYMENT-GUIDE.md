# New API v1.6.1 部署指南

## 📦 可用文件

### 1. Docker 镜像
- **文件**: `new-api-v1.6.1-docker-image.tar.gz` (65MB)
- **用途**: Docker 容器部署
- **平台**: 所有支持 Docker 的平台

### 2. Windows 可执行文件
- **文件**: `one-api-windows-amd64.exe` (36MB)
- **用途**: Windows 直接运行
- **平台**: Windows 64位

## 🚀 部署方式

### 方式一：Docker 部署（推荐）

#### 1. 导入镜像
```bash
# 解压并导入镜像
gunzip new-api-v1.6.1-docker-image.tar.gz
docker load -i new-api-v1.6.1-docker-image.tar

# 验证镜像
docker images | grep new-api
```

#### 2. 运行容器
```bash
# 基础运行
docker run -d \
  --name new-api \
  -p 3000:3000 \
  new-api:v1.6.1

# 完整配置运行
docker run -d \
  --name new-api \
  -p 3000:3000 \
  -v /path/to/data:/data \
  -e DATABASE_URL="your_database_url" \
  -e REDIS_URL="your_redis_url" \
  --restart unless-stopped \
  new-api:v1.6.1
```

#### 3. 使用 Docker Compose
```yaml
version: '3.8'
services:
  new-api:
    image: new-api:v1.6.1
    container_name: new-api
    ports:
      - "3000:3000"
    volumes:
      - ./data:/data
    environment:
      - DATABASE_URL=sqlite:///data/new-api.db
    restart: unless-stopped
```

### 方式二：Windows 直接运行

#### 1. 下载并运行
```cmd
# 下载文件后，直接双击运行
# 或在命令行中运行：
one-api-windows-amd64.exe

# 指定端口运行
one-api-windows-amd64.exe --port 8080
```

#### 2. 配置环境变量（可选）
```cmd
set PORT=3000
set DATABASE_URL=sqlite://./data/new-api.db
one-api-windows-amd64.exe
```

## 🔧 配置说明

### 环境变量
- `PORT`: 服务端口（默认：3000）
- `DATABASE_URL`: 数据库连接字符串
- `REDIS_URL`: Redis 连接字符串（可选）
- `SESSION_SECRET`: 会话密钥
- `LOG_LEVEL`: 日志级别（debug/info/warn/error）

### 数据目录
- `/data`: 应用数据目录
- `/data/logs`: 日志文件
- `/data/uploads`: 上传文件
- `/data/cache`: 缓存文件

## 🌐 访问应用

部署成功后，访问：
- **Web 界面**: http://localhost:3000
- **API 文档**: http://localhost:3000/api/docs
- **健康检查**: http://localhost:3000/api/status

## 🔍 故障排除

### Docker 相关
```bash
# 查看容器日志
docker logs new-api

# 进入容器调试
docker exec -it new-api sh

# 重启容器
docker restart new-api
```

### Windows 相关
- 确保 Windows Defender 没有阻止程序运行
- 检查防火墙设置是否允许端口访问
- 以管理员权限运行（如果需要）

## 📋 版本信息

- **版本**: v1.6.1
- **构建日期**: 2025-06-07
- **Go 版本**: 最新
- **Node 版本**: 18
- **基础镜像**: Alpine Linux

## ✅ 新功能

- ✅ 修复了所有 Dockerfile 构建问题
- ✅ 添加了分词器管理功能
- ✅ 改进了前端图标显示
- ✅ 增强了 SSE 包解析
- ✅ 切换到 pnpm 提高依赖管理

## 📞 支持

如有问题，请查看：
- GitHub Issues: https://github.com/lim12137/new-api/issues
- 文档: README.md
- 更新日志: CHANGELOG.md
