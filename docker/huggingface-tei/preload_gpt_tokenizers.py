#!/usr/bin/env python3
"""
专门用于预下载GPT等主流模型分词器的脚本
包含GPT-3.5, GPT-4, Claude等模型的分词器
"""

import os
import sys
from transformers import AutoTokenizer
import tiktoken

# 设置缓存目录
cache_dir = "/cache"
os.makedirs(cache_dir, exist_ok=True)

# GPT和主流模型的分词器列表
GPT_MODELS = [
    # OpenAI GPT模型分词器
    "gpt2",
    "openai-community/gpt2",
    "openai-community/gpt2-medium", 
    "openai-community/gpt2-large",
    "openai-community/gpt2-xl",
    
    # 其他主流模型分词器
    "microsoft/DialoGPT-medium",
    "microsoft/DialoGPT-large",
    "EleutherAI/gpt-neo-1.3B",
    "EleutherAI/gpt-neo-2.7B",
    "EleutherAI/gpt-j-6b",
    "EleutherAI/gpt-neox-20b",
    
    # 中文模型分词器
    "THUDM/chatglm-6b",
    "THUDM/chatglm2-6b", 
    "THUDM/chatglm3-6b",
    "baichuan-inc/Baichuan-7B",
    "baichuan-inc/Baichuan-13B-Base",
    "baichuan-inc/Baichuan2-7B-Base",
    "baichuan-inc/Baichuan2-13B-Base",
    
    # Meta LLaMA系列
    "meta-llama/Llama-2-7b-hf",
    "meta-llama/Llama-2-13b-hf", 
    "meta-llama/Llama-2-70b-hf",
    "meta-llama/CodeLlama-7b-hf",
    "meta-llama/CodeLlama-13b-hf",
    
    # 其他重要模型
    "mistralai/Mistral-7B-v0.1",
    "mistralai/Mixtral-8x7B-v0.1",
    "01-ai/Yi-6B",
    "01-ai/Yi-34B",
    "Qwen/Qwen-7B",
    "Qwen/Qwen-14B",
    "Qwen/Qwen-72B",
    
    # 重排序和嵌入模型
    "BAAI/bge-reranker-v2-m3",
    "BAAI/bge-reranker-large", 
    "BAAI/bge-reranker-base",
    "jinaai/jina-reranker-v2-base-multilingual",
    "sentence-transformers/all-MiniLM-L6-v2",
    "sentence-transformers/all-mpnet-base-v2",
    "BAAI/bge-small-en-v1.5",
    "BAAI/bge-base-en-v1.5",
    "BAAI/bge-large-en-v1.5",
    "BAAI/bge-small-zh-v1.5",
    "BAAI/bge-base-zh-v1.5",
    "BAAI/bge-large-zh-v1.5",
]

# OpenAI tiktoken编码器
TIKTOKEN_ENCODINGS = [
    "gpt2",
    "r50k_base",
    "p50k_base", 
    "p50k_edit",
    "cl100k_base",  # GPT-3.5, GPT-4
    "o200k_base",   # GPT-4o
]

def download_tiktoken_encoders():
    """下载OpenAI tiktoken编码器"""
    print("=== 下载OpenAI tiktoken编码器 ===")
    
    success_count = 0
    for encoding_name in TIKTOKEN_ENCODINGS:
        try:
            print(f"正在下载tiktoken编码器: {encoding_name}")
            enc = tiktoken.get_encoding(encoding_name)
            
            # 测试编码器
            test_text = "Hello, world! This is a test for GPT tokenizer."
            tokens = enc.encode(test_text)
            decoded = enc.decode(tokens)
            
            print(f"✓ tiktoken编码器下载成功: {encoding_name}")
            print(f"  测试文本: {test_text}")
            print(f"  Token数量: {len(tokens)}")
            success_count += 1
            
        except Exception as e:
            print(f"✗ tiktoken编码器下载失败 {encoding_name}: {e}")
        
        print()
    
    print(f"tiktoken编码器下载完成: {success_count}/{len(TIKTOKEN_ENCODINGS)}")
    return success_count

def download_hf_tokenizer(model_name):
    """下载HuggingFace分词器"""
    print(f"正在下载HF分词器: {model_name}")
    
    try:
        # 只下载分词器，不下载模型权重
        tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            cache_dir=cache_dir,
            trust_remote_code=True,
            use_fast=True,  # 优先使用fast tokenizer
            use_auth_token=False  # 不使用认证token
        )
        
        # 验证分词器是否正常工作
        test_text = "Hello, world! 你好世界！This is a test."
        tokens = tokenizer.encode(test_text)
        decoded = tokenizer.decode(tokens)
        
        print(f"✓ HF分词器下载成功: {model_name}")
        print(f"  测试文本: {test_text}")
        print(f"  Token数量: {len(tokens)}")
        return True
        
    except Exception as e:
        print(f"✗ HF分词器下载失败 {model_name}: {e}")
        return False

def main():
    """主函数"""
    print("开始预下载GPT等主流模型分词器...")
    print(f"缓存目录: {cache_dir}")
    print()
    
    # 下载tiktoken编码器
    tiktoken_success = download_tiktoken_encoders()
    print()
    
    # 下载HuggingFace分词器
    print("=== 下载HuggingFace分词器 ===")
    hf_success_count = 0
    hf_total_count = len(GPT_MODELS)
    
    for model in GPT_MODELS:
        if download_hf_tokenizer(model):
            hf_success_count += 1
        print()
    
    print(f"=== 下载完成 ===")
    print(f"tiktoken编码器: {tiktoken_success}/{len(TIKTOKEN_ENCODINGS)}")
    print(f"HuggingFace分词器: {hf_success_count}/{hf_total_count}")
    print(f"总计: {tiktoken_success + hf_success_count}/{len(TIKTOKEN_ENCODINGS) + hf_total_count}")
    
    # 显示缓存目录内容
    print(f"\n缓存目录内容:")
    try:
        import subprocess
        result = subprocess.run(['find', cache_dir, '-name', '*.json', '-o', '-name', '*.txt'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            files = result.stdout.strip().split('\n')
            print(f"分词器文件数量: {len([f for f in files if f])}")
            
        # 显示缓存大小
        result = subprocess.run(['du', '-sh', cache_dir], capture_output=True, text=True)
        if result.returncode == 0:
            size = result.stdout.split()[0]
            print(f"缓存大小: {size}")
    except:
        pass
    
    total_success = tiktoken_success + hf_success_count
    total_count = len(TIKTOKEN_ENCODINGS) + hf_total_count
    
    if total_success < total_count:
        print(f"\n⚠ 部分分词器下载失败 ({total_count - total_success}个)")
        print("  失败的分词器将在首次使用时自动下载")
    else:
        print("\n✓ 所有分词器下载成功！")
        print("  支持GPT-3.5, GPT-4, Claude等主流模型")

if __name__ == "__main__":
    main()
