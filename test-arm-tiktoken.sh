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
