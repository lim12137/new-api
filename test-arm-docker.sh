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
