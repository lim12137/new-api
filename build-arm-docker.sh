#!/bin/bash

# ARM架构Docker镜像专用构建脚本
# 支持 ARM64 (aarch64) 和 ARMv7

set -e

VERSION="v1.0.0-self-use"
echo $VERSION > VERSION

echo "🚀 开始构建 ARM 架构 Docker 镜像..."
echo "📦 版本: $VERSION"

# 检查Docker buildx
if ! docker buildx version >/dev/null 2>&1; then
    echo "❌ Docker buildx 不可用"
    echo "请安装Docker buildx以支持多架构构建:"
    echo "  docker buildx install"
    exit 1
fi

# 检查是否有可用的ARM构建器
echo "🔧 设置构建环境..."

# 创建并使用多架构构建器
docker buildx create --name arm-builder --use --bootstrap 2>/dev/null || {
    echo "使用现有构建器..."
    docker buildx use arm-builder 2>/dev/null || docker buildx use default
}

# 检查可用平台
echo "📋 可用构建平台:"
docker buildx inspect --bootstrap | grep "Platforms:"

# 构建前端
echo "🔨 构建前端..."
cd web
npm install --silent
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$VERSION npm run build --silent
cd ..

echo "✅ 前端构建完成"

# 构建ARM64镜像
echo "🔨 构建 ARM64 Docker 镜像..."
docker buildx build \
  --platform linux/arm64 \
  --tag new-api-self-use:$VERSION-arm64 \
  --tag new-api-self-use:latest-arm64 \
  --file Dockerfile.arm-simple \
  --load \
  .

echo "✅ ARM64 镜像构建完成"

# 构建ARMv7镜像（如果支持）
echo "🔨 尝试构建 ARMv7 Docker 镜像..."
if docker buildx build \
  --platform linux/arm/v7 \
  --tag new-api-self-use:$VERSION-armv7 \
  --tag new-api-self-use:latest-armv7 \
  --file Dockerfile.arm-simple \
  --load \
  . 2>/dev/null; then
    echo "✅ ARMv7 镜像构建完成"
    ARMV7_BUILT=true
else
    echo "⚠️  ARMv7 镜像构建失败或不支持，跳过"
    ARMV7_BUILT=false
fi

# 构建多架构清单
echo "🔨 创建多架构清单..."

# 创建并推送多架构清单
docker buildx build \
  --platform linux/arm64$([ "$ARMV7_BUILT" = true ] && echo ",linux/arm/v7" || echo "") \
  --tag new-api-self-use:$VERSION-arm \
  --tag new-api-self-use:latest-arm \
  --file Dockerfile.arm-simple \
  --load \
  .

# 显示构建结果
echo ""
echo "📊 ARM Docker镜像构建结果:"
docker images | grep new-api-self-use | grep -E "(arm64|armv7|arm)"

# 创建测试脚本
echo ""
echo "📝 创建测试脚本..."

cat > test-arm-docker.sh << 'EOF'
#!/bin/bash

echo "🧪 测试 ARM Docker 镜像..."

# 测试ARM64镜像
echo "测试 ARM64 镜像..."
if docker run --rm --platform linux/arm64 new-api-self-use:latest-arm64 --version; then
    echo "✅ ARM64 镜像测试通过"
else
    echo "❌ ARM64 镜像测试失败"
fi

# 测试ARMv7镜像（如果存在）
if docker images | grep -q "armv7"; then
    echo "测试 ARMv7 镜像..."
    if docker run --rm --platform linux/arm/v7 new-api-self-use:latest-armv7 --version; then
        echo "✅ ARMv7 镜像测试通过"
    else
        echo "❌ ARMv7 镜像测试失败"
    fi
fi

echo "🎉 ARM 镜像测试完成"
EOF

chmod +x test-arm-docker.sh

echo ""
echo "🎉 ARM Docker 镜像构建完成！"
echo ""
echo "📋 构建的镜像:"
if [ "$ARMV7_BUILT" = true ]; then
    echo "  🔹 new-api-self-use:$VERSION-arm64 (ARM64)"
    echo "  🔹 new-api-self-use:$VERSION-armv7 (ARMv7)"
    echo "  🔹 new-api-self-use:$VERSION-arm (多架构清单)"
else
    echo "  🔹 new-api-self-use:$VERSION-arm64 (ARM64)"
    echo "  🔹 new-api-self-use:$VERSION-arm (ARM64 only)"
fi

echo ""
echo "📝 使用说明:"
echo ""
echo "1. 在 ARM64 设备上运行:"
echo "   docker run -d -p 3000:3000 --name new-api-arm \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:$VERSION-arm64"
echo ""
if [ "$ARMV7_BUILT" = true ]; then
echo "2. 在 ARMv7 设备上运行:"
echo "   docker run -d -p 3000:3000 --name new-api-arm \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:$VERSION-armv7"
echo ""
fi
echo "3. 自动选择架构:"
echo "   docker run -d -p 3000:3000 --name new-api-arm \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:$VERSION-arm"
echo ""
echo "4. 测试镜像:"
echo "   ./test-arm-docker.sh"
echo ""
echo "🎯 适用设备:"
echo "  - 树莓派 4/5 (ARM64)"
echo "  - Apple Silicon Mac (ARM64)"
echo "  - ARM服务器 (ARM64)"
if [ "$ARMV7_BUILT" = true ]; then
echo "  - 树莓派 3 (ARMv7)"
echo "  - 其他ARMv7设备"
fi
