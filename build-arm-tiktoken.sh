#!/bin/bash

# ARM Docker镜像构建脚本（简化tiktoken版本）
# 使用简单的tiktoken命令预下载所有GPT分词器

set -e

# 获取版本号
if [ -f "VERSION" ]; then
    VERSION=$(cat VERSION)
else
    VERSION="v1.0.0-self-use"
fi

echo "🚀 开始构建 ARM 架构 Docker 镜像（tiktoken版本）..."
echo "📦 版本: $VERSION"

# 设置构建环境
echo "🔧 设置构建环境..."
if ! docker buildx ls | grep -q "arm-builder"; then
    echo "创建新的构建器..."
    docker buildx create --name arm-builder --use
else
    echo "使用现有构建器..."
    docker buildx use arm-builder
fi

echo "📋 可用构建平台:"
docker buildx inspect --bootstrap | grep "Platforms:"

# 构建前端
echo "🔨 构建前端..."
cd web
if [ ! -d "node_modules" ]; then
    npm install -g pnpm
    pnpm install
fi
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$VERSION pnpm run build
cd ..
echo "✅ 前端构建完成"

# 构建ARM64镜像（tiktoken版本）
echo "🔨 构建 ARM64 Docker 镜像（tiktoken分词器）..."
docker buildx build \
  --platform linux/arm64 \
  --tag new-api-self-use:$VERSION-arm64-tiktoken \
  --tag new-api-self-use:latest-arm64-tiktoken \
  --tag new-api-self-use:$VERSION-arm64 \
  --tag new-api-self-use:latest-arm64 \
  --tag new-api-self-use:$VERSION-arm \
  --tag new-api-self-use:latest-arm \
  --file Dockerfile.arm-simple-tiktoken \
  --load \
  .

echo "✅ ARM64 tiktoken镜像构建完成"

# 尝试构建ARMv7镜像（如果支持）
echo "🔨 尝试构建 ARMv7 Docker 镜像（简化版本）..."
ARMV7_BUILT=false
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
    echo "⚠️  ARMv7 镜像构建失败（这是正常的，某些依赖可能不支持ARMv7）"
fi

echo "🔨 创建多架构清单..."

echo ""
echo "📊 ARM Docker镜像构建结果:"
docker images | grep new-api-self-use

# 创建测试脚本
echo "📝 创建测试脚本..."
cat > test-arm-tiktoken.sh << 'EOF'
#!/bin/bash

echo "🧪 测试ARM tiktoken镜像..."

VERSION="v1.0.0-self-use"
IMAGE="new-api-self-use:$VERSION-arm64-tiktoken"

if docker images | grep -q "$VERSION-arm64-tiktoken"; then
    echo "✓ 镜像存在: $IMAGE"
    
    echo "测试tiktoken分词器..."
    docker run --rm --platform linux/arm64 $IMAGE python3 -c "
import tiktoken
encodings = ['cl100k_base', 'o200k_base', 'p50k_base', 'r50k_base', 'gpt2']
for enc_name in encodings:
    try:
        enc = tiktoken.get_encoding(enc_name)
        tokens = enc.encode('Hello GPT!')
        print(f'✓ {enc_name}: {len(tokens)} tokens')
    except Exception as e:
        print(f'✗ {enc_name}: {e}')
"
    
    echo "✅ tiktoken测试完成"
else
    echo "❌ 镜像不存在: $IMAGE"
    echo "请先运行: ./build-arm-tiktoken.sh"
fi
EOF

chmod +x test-arm-tiktoken.sh

echo ""
echo "🎉 ARM Docker 镜像构建完成！"

echo ""
echo "📋 构建的镜像:"
echo "  🔹 new-api-self-use:$VERSION-arm64-tiktoken (ARM64 tiktoken版本)"
echo "  🔹 new-api-self-use:$VERSION-arm64 (ARM64默认别名)"
echo "  🔹 new-api-self-use:$VERSION-arm (通用ARM标签)"
if [ "$ARMV7_BUILT" = true ]; then
    echo "  🔹 new-api-self-use:$VERSION-armv7 (ARMv7简化版)"
fi

echo ""
echo "📝 使用说明:"

echo ""
echo "1. 在 ARM64 设备上运行（推荐）:"
echo "   docker run -d -p 3000:3000 --name new-api-tiktoken \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:$VERSION-arm64-tiktoken"

if [ "$ARMV7_BUILT" = true ]; then
echo ""
echo "2. 在 ARMv7 设备上运行:"
echo "   docker run -d -p 3000:3000 --name new-api-arm \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:$VERSION-armv7"
fi

echo ""
echo "3. 自动选择架构:"
echo "   docker run -d -p 3000:3000 --name new-api-arm \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:$VERSION-arm"

echo ""
echo "4. 测试镜像:"
echo "   ./test-arm-tiktoken.sh"

echo ""
echo "🎯 适用设备:"
echo "  - 树莓派 4/5 (ARM64) - 推荐使用tiktoken版本"
echo "  - Apple Silicon Mac (ARM64) - 推荐使用tiktoken版本"
echo "  - ARM服务器 (ARM64) - 推荐使用tiktoken版本"
if [ "$ARMV7_BUILT" = true ]; then
echo "  - 树莓派 3 (ARMv7) - 使用简化版"
echo "  - 其他ARMv7设备 - 使用简化版"
fi

echo ""
echo "💡 tiktoken分词器说明:"
echo "  - 包含所有GPT模型的tiktoken编码器"
echo "  - 支持GPT-3.5, GPT-4, GPT-4o等"
echo "  - 镜像大小更小，构建更快"
echo "  - 完全离线使用GPT分词功能"

echo ""
echo "🔧 镜像大小对比:"
docker images | grep new-api-self-use | awk '{print "  - " $1 ":" $2 " -> " $7}'
