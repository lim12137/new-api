#!/bin/bash

# Windows 64位专用构建脚本

set -e

VERSION="v1.0.0-self-use"
echo $VERSION > VERSION

echo "🚀 开始构建 Windows 64位版本..."
echo "📦 版本: $VERSION"

# 创建构建目录
mkdir -p build/windows

# 构建前端
echo "🔨 构建前端..."
cd web
npm install --silent
DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$VERSION npm run build --silent
cd ..

echo "✅ 前端构建完成"

# 构建Windows 64位可执行文件
echo "🔨 构建 Windows 64位可执行文件..."
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build \
  -ldflags "-s -w -X 'one-api/common.Version=$VERSION' -H windowsgui" \
  -o build/windows/new-api-self-use.exe

echo "✅ Windows可执行文件构建完成"

# 创建Windows发布包
echo "📦 创建Windows发布包..."

cd build/windows

# 创建README文件
cat > README.txt << 'EOF'
New API Self-Use Mode - Windows 版本
====================================

这是专为个人使用优化的New API版本。

快速开始:
1. 双击 new-api-self-use.exe 启动程序
2. 打开浏览器访问 http://localhost:3000
3. 按照设置向导完成初始化

特性:
- 自用模式专用，配置简单
- 移除了复杂的计费功能
- 预集成常用解码器支持
- 支持离线使用

注意事项:
- 首次启动可能需要较长时间初始化
- 请确保3000端口未被占用
- 建议在防火墙中允许程序访问网络

技术支持:
- GitHub: https://github.com/lim12137/new-api/tree/myself
- 文档: 查看 SELF_USE_MODE_CHANGES.md

版本: v1.0.0-self-use
构建时间: $(date)
EOF

# 复制相关文档
cp ../../SELF_USE_MODE_CHANGES.md . 2>/dev/null || echo "# 详细文档请查看GitHub仓库" > SELF_USE_MODE_CHANGES.md

# 创建启动脚本
cat > start.bat << 'EOF'
@echo off
title New API Self-Use Mode
echo Starting New API Self-Use Mode...
echo.
echo Please wait while the application initializes...
echo Once started, open your browser and go to: http://localhost:3000
echo.
echo Press Ctrl+C to stop the application
echo.
new-api-self-use.exe
pause
EOF

# 创建压缩包
tar -czf ../new-api-self-use-windows-amd64.tar.gz .

cd ../..

# 显示构建结果
echo ""
echo "📊 Windows构建结果:"
ls -lh build/windows/
echo ""
echo "📦 发布包:"
ls -lh build/new-api-self-use-windows-amd64.tar.gz

echo ""
echo "🎉 Windows 64位版本构建完成！"
echo ""
echo "📋 使用说明:"
echo "1. 解压 build/new-api-self-use-windows-amd64.tar.gz"
echo "2. 双击 new-api-self-use.exe 或运行 start.bat"
echo "3. 打开浏览器访问 http://localhost:3000"
echo ""
echo "📁 包含文件:"
echo "  - new-api-self-use.exe (主程序)"
echo "  - start.bat (启动脚本)"
echo "  - README.txt (使用说明)"
echo "  - SELF_USE_MODE_CHANGES.md (详细文档)"
