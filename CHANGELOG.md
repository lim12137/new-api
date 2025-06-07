# 更新日志 (Changelog)

## [v1.6.0] - 2024-12-19

### 🎉 新增功能 (New Features)

#### Hugging Face TEI 完整集成
- **新增 Hugging Face TEI 渠道类型** - 支持 Text Embeddings Inference 服务
- **重排序 API 支持** - 完全兼容 OpenAI 重排序 API 格式
- **嵌入 API 支持** - 支持文本嵌入生成功能
- **分词器功能完全集成** - 内置分词器处理，无需外部依赖
- **30+ 预训练模型支持** - 包括 BGE、Jina、Cross-encoder 等主流重排序模型

#### 分词器管理系统 (完全集成)
- **🔥 默认预下载机制** - Docker 构建时自动下载所有支持的分词器
- **🔥 离线运行支持** - 完全支持离线环境，无需运行时下载
- **🔥 分词器功能内置** - 分词器处理完全集成到系统中，无需外部服务
- **📊 可视化管理界面** - 新增专门的分词器管理页面
- **⚡ 一键更新功能** - 支持单个/批量/全部分词器更新
- **📈 实时状态监控** - 显示分词器健康状态和缓存使用情况
- **🔧 智能缓存管理** - 自动管理分词器缓存，优化性能

### 🛠️ 技术改进 (Technical Improvements)

#### 后端架构
- **新增渠道类型** - `ChannelTypeHuggingFace = 50`
- **RESTful API** - 完整的分词器管理 API 接口
- **Docker 集成** - 与容器内管理脚本的无缝集成
- **权限控制** - 分词器管理功能仅限管理员访问

#### 前端界面
- **新增管理页面** - `/tokenizer` 路由和对应界面
- **Semi UI 组件** - 使用项目统一的 UI 组件库
- **响应式设计** - 支持桌面和移动端访问
- **实时更新** - 支持更新进度的实时显示

#### Docker 优化
- **智能缓存管理** - 优化的分词器缓存策略
- **构建验证** - 自动验证分词器下载完整性
- **多服务支持** - Docker Compose 多模型并行部署
- **健康检查** - 完善的服务健康监控

### 📦 支持的模型 (Supported Models)

#### 重排序模型
```
BAAI/bge-reranker-v2-m3          # 多语言，推荐
BAAI/bge-reranker-large          # 大型模型，高精度
BAAI/bge-reranker-base           # 基础模型，平衡性能
jinaai/jina-reranker-v2-base-multilingual
jinaai/jina-reranker-v1-base-en
jinaai/jina-reranker-v1-turbo-en
cross-encoder/ms-marco-MiniLM-L-6-v2
cross-encoder/ms-marco-MiniLM-L-12-v2
cross-encoder/ms-marco-TinyBERT-L-2-v2
mixedbread-ai/mxbai-rerank-large-v1
mixedbread-ai/mxbai-rerank-base-v1
```

#### 嵌入模型
```
sentence-transformers/all-MiniLM-L6-v2
sentence-transformers/all-MiniLM-L12-v2
sentence-transformers/all-mpnet-base-v2
BAAI/bge-small-en-v1.5
BAAI/bge-base-en-v1.5
BAAI/bge-large-en-v1.5
BAAI/bge-small-zh-v1.5
BAAI/bge-base-zh-v1.5
BAAI/bge-large-zh-v1.5
```

### 🚀 快速开始 (Quick Start)

#### 1. 部署 TEI 服务
```bash
# 克隆项目
git clone <repository-url>
cd new-api

# 构建 TEI 镜像（自动下载所有分词器）
cd docker/huggingface-tei
./build.sh

# 启动服务
docker-compose up -d
```

#### 2. 配置渠道
1. 登录 New API 管理界面
2. 进入"渠道管理" → "添加新渠道"
3. 选择渠道类型："Hugging Face TEI"
4. 配置 Base URL 和支持的模型

#### 3. 管理分词器
1. 访问"分词器管理"页面（管理员专用）
2. 查看所有分词器状态
3. 根据需要进行更新操作

### 📋 API 使用示例 (API Examples)

#### 重排序 API
```bash
curl -X POST "http://your-api-host/v1/rerank" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "BAAI/bge-reranker-v2-m3",
    "query": "机器学习的基本概念",
    "documents": [
      "机器学习是人工智能的一个分支",
      "深度学习使用神经网络",
      "自然语言处理专注于语言理解"
    ],
    "top_n": 2,
    "return_documents": true
  }'
```

#### 嵌入 API
```bash
curl -X POST "http://your-api-host/v1/embeddings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "sentence-transformers/all-MiniLM-L6-v2",
    "input": ["Hello world", "你好世界"]
  }'
```

### 📁 新增文件 (New Files)

#### 后端文件
- `controller/tokenizer.go` - 分词器管理控制器
- `relay/channel/huggingface/` - HuggingFace 渠道实现
  - `constants.go` - 模型列表和常量
  - `dto.go` - 请求/响应结构体
  - `adaptor.go` - 适配器接口实现
  - `relay-huggingface.go` - 请求处理逻辑

#### 前端文件
- `web/src/pages/Tokenizer/index.js` - 分词器管理界面

#### Docker 文件
- `docker/huggingface-tei/` - TEI 部署配置
  - `Dockerfile` - 包含预下载的镜像
  - `docker-compose.yml` - 多服务部署配置
  - `preload_all_tokenizers.py` - 分词器预下载脚本
  - `tokenizer_manager.py` - 分词器管理工具
  - `build.sh` - 自动化构建脚本

#### 测试文件
- `test/huggingface_tei_test.go` - 完整的单元测试
- `test/integration_test.sh` - Docker 集成测试

#### 文档文件
- `docs/HUGGINGFACE_TEI_RERANK.md` - 功能使用指南
- `docs/DEPLOYMENT_GUIDE.md` - 详细部署指南
- `docs/TOKENIZER_MANAGEMENT.md` - 分词器管理指南

### 🔧 修改文件 (Modified Files)

#### 核心配置
- `common/constants.go` - 添加 HuggingFace 渠道类型
- `relay/constant/api_type.go` - 添加 API 类型映射
- `relay/relay_adaptor.go` - 注册新适配器

#### 路由配置
- `router/api-router.go` - 添加分词器管理路由
- `web/src/App.js` - 添加前端路由
- `web/src/components/SiderBar.js` - 添加菜单项

#### 前端配置
- `web/src/constants/channel.constants.js` - 添加渠道选项

### ⚡ 性能特点 (Performance Features)

- **低延迟启动** - 预下载分词器避免首次使用延迟
- **高并发支持** - 支持最多 256 个并发请求
- **GPU 加速** - 充分利用 GPU 资源进行推理
- **智能批处理** - 优化内存使用和处理效率
- **离线运行** - 完全支持离线环境部署

### 🛡️ 安全改进 (Security Improvements)

- **权限控制** - 分词器管理功能仅限管理员
- **API 认证** - 支持 Bearer Token 认证
- **操作审计** - 记录所有管理操作日志
- **容器安全** - 最小权限原则和安全配置

### 📊 监控和维护 (Monitoring & Maintenance)

- **健康检查** - 自动检测服务和分词器状态
- **状态监控** - 实时显示系统运行状态
- **缓存管理** - 智能缓存清理和优化
- **更新机制** - 灵活的分词器更新策略

### 🐛 问题修复 (Bug Fixes)

- 优化了渠道类型映射逻辑
- 修复了并发请求处理问题
- 改进了错误处理和日志记录
- 优化了内存使用和性能

### 📚 文档更新 (Documentation Updates)

- 新增完整的部署指南
- 添加 API 使用示例
- 提供故障排除指南
- 包含最佳实践建议

---

### 🙏 致谢 (Acknowledgments)

感谢 Hugging Face 团队提供的优秀 TEI 服务，以及所有模型作者的贡献。

### 📞 支持 (Support)

如有问题或建议，请通过以下方式联系：
- GitHub Issues
- 项目文档
- 社区讨论

---

**完整更新内容请参考项目文档和代码变更记录。**
