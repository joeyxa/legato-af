# Legato 基础组件功能验证方案

## 文档说明

本文档用于记录 Legato 框架基础组件的功能验证方案，包含测试环境、验证步骤、预期结果等内容。文档将持续更新，逐步覆盖各核心组件的验证方法。

---

## 目录

1. [内存池（MemPool）功能验证](#1-内存池mempool功能验证)
   - 1.1 验证目的
   - 1.2 验证环境
   - 1.3 验证步骤
   - 1.4 预期结果
   - 1.5 实际执行

---

## 1. 内存池（MemPool）功能验证

### 1.1 验证目的

验证 Legato 框架内存池组件的核心功能，包括：
- 内存块的分配与释放
- 内存池的动态扩展
- 内存对齐与边界检查
- 内存泄漏检测

### 1.2 验证环境

| 项目 | 说明 |
|------|------|
| 目标平台 | localhost（与硬件无关） |
| Legato 版本 | 19.11.0+ |
| 编译命令 | `make localhost` + `make tests_c` |
| 测试应用 | test_MemPool |

### 1.3 验证步骤

#### 步骤 1：确认测试应用已编译

```bash
# 检查测试应用是否存在
ls -la /home/zhaoming/legato/build/localhost/testFramework/app/test_MemPool/
```

#### 步骤 2：进入测试目录

```bash
cd /home/zhaoming/legato/build/localhost/testFramework/app/test_MemPool/staging/read-only/bin/
```

#### 步骤 3：执行测试

```bash
./testMemPool
```

### 1.4 预期结果

测试应用使用 **TAP（Test Anything Protocol）格式**输出测试结果。正常执行应输出类似以下内容：

```
Apr 30 16:16:25 :  INFO | testMemPool[139410]/memComponent T=main | main.c TestPools() 474 | TAP | ok 1185 - allocate buffer 8 (size 239)
Apr 30 16:16:25 :  INFO | testMemPool[139410]/memComponent T=main | main.c TestPools() 491 | TAP | ok 1186 - got a large object
...
Apr 30 16:16:25 :  INFO | testMemPool[139410]/memComponent T=main | main.c _memComponent_COMPONENT_INIT() 638 | TAP | # Done le_mem unit test
Apr 30 16:16:25 :  INFO | testMemPool[139410]/memComponent T=main | main.c _memComponent_COMPONENT_INIT() 639 | TAP | 1..1207
```

**输出解读**：
- `TAP | ok N` - 表示第 N 个测试用例通过
- `TAP | # Done le_mem unit test` - 测试完成提示
- `TAP | 1..1207` - 表示总共执行了 1207 个测试用例

**验证成功标志**：
1. 输出中无 `not ok` 字样（表示无失败测试）
2. 最终输出 `1..N`（N 为测试用例总数）
3. 无错误日志输出

### 1.5 实际执行命令

```bash
# 完整执行流程
cd /home/zhaoming/legato/build/localhost/testFramework/app/test_MemPool/staging/read-only/bin/
./testMemPool
```

---

## 附录

### A. 测试应用位置说明

| 组件 | 路径 |
|------|------|
| test_MemPool | `build/localhost/testFramework/app/test_MemPool/` |
| test_Thread | `build/localhost/testFramework/app/test_Thread/` |
| test_Timer | `build/localhost/testFramework/app/test_Timer/` |

### B. 常用命令参考

```bash
# 编译所有测试组件
make tests_c

# 查看测试应用列表
find build/localhost -name "test_*" -type d | grep -E "test_[A-Za-z]+"

# 运行单个测试
cd build/localhost/testFramework/app/test_<Name>/staging/read-only/bin/
./test<Name>
```

---

**文档版本**: v1.0  
**创建日期**: 2026-04-30  
**更新记录**:
- 2026-04-30: 创建文档，添加内存池验证章节