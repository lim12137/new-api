# 自用模式专用版本修改说明

本版本已针对自用模式进行了深度优化，删除了其他模式和所有计价模块，并集成了预下载的解码器。

## 主要修改内容

### 1. 删除其他模式，只保留自用模式

#### 后端修改
- `setting/operation_setting/operation_setting.go`: 强制启用自用模式，移除演示站点模式
- `controller/setup.go`: 移除模式选择，强制设置为自用模式
- `controller/misc.go`: 状态接口只返回自用模式

#### 前端修改
- `web/src/pages/Setup/index.js`: 移除模式选择界面，显示自用模式说明
- `web/src/pages/Setting/Operation/SettingsGeneral.js`: 移除模式开关，显示自用模式状态

### 2. 删除所有计价模块

#### 删除的后端文件
- `relay/helper/price.go`: 价格计算辅助函数
- `model/pricing.go`: 价格模型
- `controller/pricing.go`: 价格控制器
- `controller/billing.go`: 账单控制器
- `controller/channel-billing.go`: 渠道账单控制器
- `controller/redemption.go`: 兑换码控制器

#### 删除的前端文件
- `web/src/pages/Pricing/index.js`: 价格页面
- `web/src/components/ModelPricing.js`: 价格组件
- `web/src/pages/Redemption/`: 兑换码相关页面
- `web/src/components/RedemptionsTable.js`: 兑换码表格组件

#### 修改的路由
- `router/api-router.go`: 移除价格和兑换码相关路由
- `router/dashboard.go`: 移除计费相关接口
- `web/src/App.js`: 移除价格和兑换码路由
- `web/src/components/SiderBar.js`: 移除相关菜单项

#### 简化的配额逻辑
- `service/quota.go`: 自用模式下简化配额计算
- `setting/operation_setting/model-ratio.go`: 自用模式下固定倍率为1.0
- `setting/operation_setting/cache_ratio.go`: 自用模式下简化缓存倍率

### 3. 集成预下载的解码器

#### Dockerfile修改
- 添加了多阶段构建，包含解码器预下载阶段
- 集成了`docker/huggingface-tei/preload_tokenizers.py`脚本
- 预下载常用的重排序和嵌入模型解码器
- 安装了Python运行时环境和解码器管理工具

#### 预下载的模型
包含以下模型的解码器：
- 重排序模型：BAAI/bge-reranker-v2-m3, jinaai/jina-reranker-v2-base-multilingual等
- 嵌入模型：sentence-transformers/all-MiniLM-L6-v2, BAAI/bge-large-zh-v1.5等

#### 解码器管理
- 集成了`tokenizer_manager.py`脚本用于运行时管理
- 解码器缓存位置：`/data/cache`
- 支持离线使用和验证

## 使用说明

### 快速构建
使用提供的构建脚本：
```bash
./build-self-use.sh
```

### 手动构建
```bash
# 构建前端
cd web && npm install && DISABLE_ESLINT_PLUGIN='true' npm run build && cd ..

# 构建后端
go build -ldflags "-s -w -X 'one-api/common.Version=v1.0.0-self-use'" -o new-api-self-use

# 构建Docker镜像
docker build -t new-api-self-use .
```

### 运行方式

#### 直接运行
```bash
./new-api-self-use
```

#### Docker运行
```bash
docker run -d \
  --name new-api-self-use \
  -p 3000:3000 \
  -v ./data:/data \
  new-api-self-use:latest
```

### 解码器管理
```bash
# 查看已下载的解码器
docker exec new-api-self-use python3 /usr/local/bin/tokenizer_manager.py list

# 验证解码器完整性
docker exec new-api-self-use python3 /usr/local/bin/tokenizer_manager.py verify

# 更新所有解码器
docker exec new-api-self-use python3 /usr/local/bin/tokenizer_manager.py update-all
```

## 测试

运行测试以验证自用模式配置：
```bash
go test ./test/self_use_mode_test.go -v
```

预期输出：
```
=== RUN   TestSelfUseModeEnabled
--- PASS: TestSelfUseModeEnabled (0.00s)
=== RUN   TestModelRatioInSelfUseMode
--- PASS: TestModelRatioInSelfUseMode (0.00s)
=== RUN   TestCacheRatioInSelfUseMode
--- PASS: TestCacheRatioInSelfUseMode (0.00s)
=== RUN   TestCreateCacheRatioInSelfUseMode
--- PASS: TestCreateCacheRatioInSelfUseMode (0.00s)
PASS
```

## 注意事项

1. 本版本专为自用模式设计，不支持多用户运营
2. 所有价格计算和计费功能已被移除
3. 解码器已预下载，支持离线使用
4. 配额计算已简化，主要用于基本的使用统计

## 优势

- **简化配置**: 无需复杂的价格和倍率设置
- **离线支持**: 预下载解码器，无需网络连接
- **专注体验**: 移除不必要的功能，专注于核心AI服务
- **资源优化**: 减少了不必要的计算和存储开销
- **易于部署**: 一键构建脚本，开箱即用
- **完整测试**: 包含完整的测试套件验证功能

## 构建验证

本次修改已通过以下验证：

1. ✅ **编译测试**: Go代码成功编译，生成可执行文件
2. ✅ **功能测试**: 所有自用模式相关测试通过
3. ✅ **前端构建**: React前端成功构建
4. ✅ **Docker集成**: Dockerfile包含解码器预下载
5. ✅ **文档完整**: 提供详细的使用说明和修改记录

## 文件清单

### 新增文件
- `test/self_use_mode_test.go` - 自用模式测试
- `relay/simple_price_helper.go` - 简化价格辅助函数
- `build-self-use.sh` - 一键构建脚本
- `SELF_USE_MODE_CHANGES.md` - 修改说明文档

### 删除文件
- `relay/helper/price.go` - 价格计算辅助函数
- `model/pricing.go` - 价格模型
- `controller/pricing.go` - 价格控制器
- `controller/billing.go` - 账单控制器
- `controller/channel-billing.go` - 渠道账单控制器
- `controller/redemption.go` - 兑换码控制器
- `web/src/pages/Pricing/` - 价格相关前端页面
- `web/src/pages/Redemption/` - 兑换码相关前端页面

### 修改文件
- `setting/operation_setting/operation_setting.go` - 强制启用自用模式
- `controller/setup.go` - 移除模式选择
- `service/quota.go` - 简化配额计算
- `Dockerfile` - 集成解码器预下载
- 多个路由和前端文件 - 移除计价相关功能

## 总结

本次修改成功将原有的多模式系统转换为专门的自用模式版本，删除了所有计价模块，简化了系统架构，并集成了解码器预下载功能。修改后的系统更适合个人使用，配置简单，功能专注，支持离线部署。
