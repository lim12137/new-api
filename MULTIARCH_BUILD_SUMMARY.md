# 多架构构建总结

本文档总结了New API自用模式的多架构构建结果。

## 🎯 构建目标

- ✅ ARM64 Docker镜像
- ✅ ARMv7 Docker镜像  
- ✅ Windows 64位可执行文件
- ✅ Linux AMD64/ARM64 二进制文件
- ✅ macOS AMD64/ARM64 二进制文件

## 📦 构建结果

### 二进制文件

| 平台 | 文件名 | 大小 | 压缩包 |
|------|--------|------|--------|
| Linux AMD64 | new-api-self-use-linux-amd64 | 35MB | 13MB |
| Linux ARM64 | new-api-self-use-linux-arm64 | 33MB | 12MB |
| Windows AMD64 | new-api-self-use-windows-amd64.exe | 35MB | 13MB |
| macOS AMD64 | new-api-self-use-darwin-amd64 | 35MB | 13MB |
| macOS ARM64 | new-api-self-use-darwin-arm64 | 34MB | 13MB |

### Docker镜像

| 架构 | 镜像标签 | 大小 | 说明 |
|------|----------|------|------|
| ARM64 | new-api-self-use:v1.0.0-self-use-arm64 | 156MB | ARM64架构 |
| ARMv7 | new-api-self-use:v1.0.0-self-use-armv7 | 118MB | ARMv7架构 |

## 🚀 使用说明

### 二进制文件使用

#### Linux (AMD64/ARM64)
```bash
# 下载对应架构的文件
wget https://github.com/lim12137/new-api/releases/download/v1.0.0-self-use/new-api-self-use-linux-amd64.tar.gz

# 解压
tar -xzf new-api-self-use-linux-amd64.tar.gz

# 运行
chmod +x new-api-self-use-linux-amd64
./new-api-self-use-linux-amd64
```

#### Windows 64位
```cmd
# 下载并解压
# new-api-self-use-windows-amd64.tar.gz

# 运行
new-api-self-use-windows-amd64.exe
```

#### macOS (Intel/Apple Silicon)
```bash
# Intel Mac
wget https://github.com/lim12137/new-api/releases/download/v1.0.0-self-use/new-api-self-use-darwin-amd64.tar.gz

# Apple Silicon Mac
wget https://github.com/lim12137/new-api/releases/download/v1.0.0-self-use/new-api-self-use-darwin-arm64.tar.gz

# 解压并运行
tar -xzf new-api-self-use-darwin-*.tar.gz
chmod +x new-api-self-use-darwin-*
./new-api-self-use-darwin-*
```

### Docker使用

#### ARM64设备 (树莓派4/5, Apple Silicon Mac, ARM服务器)
```bash
docker run -d \
  --name new-api-self-use \
  -p 3000:3000 \
  -v ./data:/data \
  new-api-self-use:v1.0.0-self-use-arm64
```

#### ARMv7设备 (树莓派3)
```bash
docker run -d \
  --name new-api-self-use \
  -p 3000:3000 \
  -v ./data:/data \
  new-api-self-use:v1.0.0-self-use-armv7
```

## 🛠️ 构建脚本

### 快速构建所有平台
```bash
./build-multiarch.sh
```

### 仅构建Windows版本
```bash
./build-windows.sh
```

### 仅构建ARM Docker镜像
```bash
./build-arm-docker.sh
```

## 📋 适用设备

### ARM64
- 树莓派 4/5
- Apple Silicon Mac (M1/M2/M3)
- ARM64 服务器
- NVIDIA Jetson 系列
- AWS Graviton 实例

### ARMv7
- 树莓派 3
- 其他ARMv7设备

### x86_64
- 标准PC/服务器
- Intel Mac
- Windows PC
- 云服务器实例

## 🔧 技术细节

### 构建环境
- Go 1.21+ (交叉编译)
- Node.js 18+ (前端构建)
- Docker Buildx (多架构镜像)

### 优化特性
- 静态链接 (无依赖)
- 压缩优化 (-ldflags "-s -w")
- 多阶段Docker构建
- 前端资源压缩

### 自用模式特性
- 强制启用自用模式
- 移除计费模块
- 简化配额计算
- 专注个人使用

## 📝 注意事项

1. **ARM镜像说明**: ARM版本的Docker镜像为了简化构建，暂时不包含预下载的解码器，解码器将在首次使用时自动下载。

2. **Windows版本**: Windows版本为控制台应用，可以通过提供的start.bat脚本启动。

3. **macOS权限**: macOS版本首次运行可能需要在系统偏好设置中允许运行。

4. **端口配置**: 默认监听3000端口，可通过环境变量PORT修改。

## 🎉 总结

本次多架构构建成功生成了：
- **5个**不同平台的二进制文件
- **2个**不同架构的Docker镜像
- **完整的**使用文档和构建脚本

所有版本都基于自用模式优化，专注于个人使用场景，配置简单，功能专一。
