#!/bin/bash

# 自用模式专用版本构建脚本
# 包含解码器预下载和优化配置

set -e

echo "🚀 开始构建自用模式专用版本..."

# 设置版本信息
VERSION="v1.0.0-self-use"
echo $VERSION > VERSION

echo "📦 版本: $VERSION"

# 构建前端
echo "🔨 构建前端..."
cd web
npm install --silent
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$VERSION npm run build --silent
cd ..

# 构建后端
echo "🔨 构建后端..."
go build -ldflags "-s -w -X 'one-api/common.Version=$VERSION'" -o new-api-self-use

echo "✅ 构建完成！"

# 显示构建结果
echo ""
echo "📊 构建结果:"
echo "  可执行文件: new-api-self-use"
ls -lh new-api-self-use

echo "  前端文件: web/build/"
du -sh web/build/

echo ""
echo "🐳 构建Docker镜像..."
docker build -t new-api-self-use:$VERSION .
docker tag new-api-self-use:$VERSION new-api-self-use:latest

echo "✅ Docker镜像构建完成！"

echo ""
echo "📋 使用说明:"
echo ""
echo "1. 直接运行:"
echo "   ./new-api-self-use"
echo ""
echo "2. Docker运行:"
echo "   docker run -d --name new-api-self-use \\"
echo "     -p 3000:3000 \\"
echo "     -v ./data:/data \\"
echo "     new-api-self-use:latest"
echo ""
echo "3. 解码器管理:"
echo "   docker exec new-api-self-use python3 /usr/local/bin/tokenizer_manager.py list"
echo "   docker exec new-api-self-use python3 /usr/local/bin/tokenizer_manager.py verify"
echo ""
echo "🎉 自用模式专用版本构建完成！"
echo ""
echo "✨ 主要特性:"
echo "  - 强制启用自用模式"
echo "  - 移除所有计价模块"
echo "  - 简化配额计算"
echo "  - 预下载常用解码器"
echo "  - 支持离线使用"
echo ""
echo "📝 详细说明请查看: SELF_USE_MODE_CHANGES.md"
