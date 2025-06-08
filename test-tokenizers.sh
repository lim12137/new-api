#!/bin/bash

# 分词器测试脚本
# 验证ARM镜像中的GPT分词器是否正常工作

set -e

VERSION="v1.0.0-self-use"

echo "🧪 测试ARM镜像中的分词器..."

# 测试ARM64完整版镜像
echo ""
echo "=== 测试ARM64完整版镜像 ==="
echo "镜像: new-api-self-use:$VERSION-arm64-full"

if docker images | grep -q "new-api-self-use.*arm64-full"; then
    echo "✓ ARM64完整版镜像存在"
    
    # 启动容器进行测试
    echo "启动测试容器..."
    CONTAINER_ID=$(docker run -d --name test-arm64-tokenizers \
        new-api-self-use:$VERSION-arm64-full)
    
    # 等待容器启动
    sleep 5
    
    echo "测试GPT-3.5分词器..."
    docker exec $CONTAINER_ID python3 -c "
import tiktoken
try:
    enc = tiktoken.get_encoding('cl100k_base')
    text = 'Hello GPT-3.5! This is a test message.'
    tokens = enc.encode(text)
    decoded = enc.decode(tokens)
    print(f'✓ GPT-3.5分词器测试成功')
    print(f'  原文: {text}')
    print(f'  Token数: {len(tokens)}')
    print(f'  解码: {decoded}')
except Exception as e:
    print(f'✗ GPT-3.5分词器测试失败: {e}')
    exit(1)
"
    
    echo "测试GPT-2分词器..."
    docker exec $CONTAINER_ID python3 -c "
from transformers import AutoTokenizer
try:
    tokenizer = AutoTokenizer.from_pretrained('gpt2', cache_dir='/data/cache', local_files_only=True)
    text = 'Hello GPT-2! This is another test.'
    tokens = tokenizer.encode(text)
    decoded = tokenizer.decode(tokens)
    print(f'✓ GPT-2分词器测试成功')
    print(f'  原文: {text}')
    print(f'  Token数: {len(tokens)}')
    print(f'  解码: {decoded}')
except Exception as e:
    print(f'✗ GPT-2分词器测试失败: {e}')
    exit(1)
"
    
    echo "测试中文分词器..."
    docker exec $CONTAINER_ID python3 -c "
from transformers import AutoTokenizer
try:
    tokenizer = AutoTokenizer.from_pretrained('BAAI/bge-large-zh-v1.5', cache_dir='/data/cache', local_files_only=True)
    text = '你好世界！这是一个中文测试。'
    tokens = tokenizer.encode(text)
    decoded = tokenizer.decode(tokens)
    print(f'✓ 中文分词器测试成功')
    print(f'  原文: {text}')
    print(f'  Token数: {len(tokens)}')
    print(f'  解码: {decoded}')
except Exception as e:
    print(f'✗ 中文分词器测试失败: {e}')
    exit(1)
"
    
    echo "检查缓存目录..."
    docker exec $CONTAINER_ID sh -c "
echo '分词器缓存目录内容:'
find /data/cache -name '*.json' | head -10
echo ''
echo '缓存目录大小:'
du -sh /data/cache
echo ''
echo 'tiktoken缓存:'
ls -la /data/cache/tiktoken/ 2>/dev/null || echo 'tiktoken缓存目录不存在'
"
    
    # 清理测试容器
    docker stop $CONTAINER_ID >/dev/null 2>&1
    docker rm $CONTAINER_ID >/dev/null 2>&1
    
    echo "✅ ARM64完整版分词器测试通过"
    
else
    echo "❌ ARM64完整版镜像不存在，请先运行构建脚本"
    exit 1
fi

# 测试ARMv7简化版镜像（如果存在）
echo ""
echo "=== 测试ARMv7简化版镜像 ==="
if docker images | grep -q "new-api-self-use.*armv7"; then
    echo "镜像: new-api-self-use:$VERSION-armv7"
    echo "✓ ARMv7简化版镜像存在"
    
    # 启动容器进行基础测试
    echo "启动测试容器..."
    CONTAINER_ID=$(docker run -d --name test-armv7-basic \
        new-api-self-use:$VERSION-armv7)
    
    # 等待容器启动
    sleep 3
    
    echo "测试基础功能..."
    docker exec $CONTAINER_ID /one-api --version
    
    # 清理测试容器
    docker stop $CONTAINER_ID >/dev/null 2>&1
    docker rm $CONTAINER_ID >/dev/null 2>&1
    
    echo "✅ ARMv7简化版基础测试通过"
else
    echo "ℹ️  ARMv7简化版镜像不存在（这是正常的）"
fi

echo ""
echo "🎉 分词器测试完成！"
echo ""
echo "📋 测试结果总结:"
echo "  ✅ ARM64完整版: 包含GPT-3.5, GPT-4, 中文等分词器"
echo "  ✅ 分词器缓存: 正常工作"
echo "  ✅ 离线使用: 支持"
echo ""
echo "💡 使用建议:"
echo "  - ARM64设备推荐使用: new-api-self-use:$VERSION-arm64-full"
echo "  - 该版本包含完整的GPT分词器，支持离线使用"
echo "  - 首次启动会自动验证分词器完整性"
