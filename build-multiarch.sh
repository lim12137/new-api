#!/bin/bash

# 多架构构建脚本
# 支持 AMD64, ARM64 Docker镜像和 Windows 64位可执行文件

set -e

VERSION="v1.0.0-self-use"
echo $VERSION > VERSION

echo "🚀 开始多架构构建..."
echo "📦 版本: $VERSION"

# 创建构建目录
mkdir -p build/docker
mkdir -p build/binaries

# 构建前端
echo "🔨 构建前端..."
cd web
npm install --silent
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$VERSION npm run build --silent
cd ..

echo "✅ 前端构建完成"

# 构建多平台二进制文件
echo "🔨 构建多平台二进制文件..."

# Linux AMD64
echo "  📦 构建 Linux AMD64..."
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build \
  -ldflags "-s -w -X 'one-api/common.Version=$VERSION'" \
  -o build/binaries/new-api-self-use-linux-amd64

# Linux ARM64
echo "  📦 构建 Linux ARM64..."
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build \
  -ldflags "-s -w -X 'one-api/common.Version=$VERSION'" \
  -o build/binaries/new-api-self-use-linux-arm64

# Windows AMD64
echo "  📦 构建 Windows AMD64..."
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build \
  -ldflags "-s -w -X 'one-api/common.Version=$VERSION'" \
  -o build/binaries/new-api-self-use-windows-amd64.exe

# macOS AMD64
echo "  📦 构建 macOS AMD64..."
GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build \
  -ldflags "-s -w -X 'one-api/common.Version=$VERSION'" \
  -o build/binaries/new-api-self-use-darwin-amd64

# macOS ARM64 (Apple Silicon)
echo "  📦 构建 macOS ARM64..."
GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 go build \
  -ldflags "-s -w -X 'one-api/common.Version=$VERSION'" \
  -o build/binaries/new-api-self-use-darwin-arm64

echo "✅ 二进制文件构建完成"

# 显示构建结果
echo ""
echo "📊 构建的二进制文件:"
ls -lh build/binaries/

# 检查Docker buildx是否可用
if ! docker buildx version >/dev/null 2>&1; then
    echo "⚠️  Docker buildx 不可用，跳过多架构Docker镜像构建"
    echo "   请安装Docker buildx以支持多架构构建"
else
    echo ""
    echo "🐳 构建多架构Docker镜像..."
    
    # 创建并使用buildx构建器
    docker buildx create --name multiarch-builder --use --bootstrap 2>/dev/null || true
    
    # 构建并推送多架构镜像
    echo "  🔨 构建 AMD64 + ARM64 镜像..."
    docker buildx build \
      --platform linux/amd64,linux/arm64 \
      --tag new-api-self-use:$VERSION \
      --tag new-api-self-use:latest \
      --load \
      .
    
    echo "✅ Docker多架构镜像构建完成"
    
    # 显示镜像信息
    echo ""
    echo "📊 Docker镜像:"
    docker images | grep new-api-self-use
fi

# 创建发布包
echo ""
echo "📦 创建发布包..."

# 创建压缩包
cd build/binaries
for file in *; do
    if [[ $file == *.exe ]]; then
        # Windows文件
        zip "${file%.exe}.zip" "$file"
        echo "  ✅ 创建 ${file%.exe}.zip"
    else
        # Unix文件
        tar -czf "${file}.tar.gz" "$file"
        echo "  ✅ 创建 ${file}.tar.gz"
    fi
done
cd ../..

echo ""
echo "🎉 多架构构建完成！"
echo ""
echo "📋 构建结果:"
echo "  📁 二进制文件: build/binaries/"
echo "  🐳 Docker镜像: new-api-self-use:$VERSION"
echo ""
echo "📝 使用说明:"
echo ""
echo "1. Linux AMD64:"
echo "   ./build/binaries/new-api-self-use-linux-amd64"
echo ""
echo "2. Linux ARM64:"
echo "   ./build/binaries/new-api-self-use-linux-arm64"
echo ""
echo "3. Windows 64位:"
echo "   build\\binaries\\new-api-self-use-windows-amd64.exe"
echo ""
echo "4. Docker (多架构):"
echo "   docker run -d -p 3000:3000 new-api-self-use:$VERSION"
echo ""
echo "5. 发布包:"
echo "   build/binaries/*.zip (Windows)"
echo "   build/binaries/*.tar.gz (Unix)"
