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

2. [事件循环（EventLoop）功能验证](#2-事件循环eventloop功能验证)
   - 2.1 验证目的
   - 2.2 验证环境
   - 2.3 验证步骤
   - 2.4 预期结果
   - 2.5 实际执行

3. [定时器（Timer）功能验证](#3-定时器timer功能验证)
   - 3.1 验证目的
   - 3.2 验证环境
   - 3.3 验证步骤
   - 3.4 预期结果
   - 3.5 实际执行

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
Apr 30 16:16:25 :  INFO | testMemPool[139410]/memComponent T=main | main.c _memComponent_COMPONENT_INIT() 638 | TAP | # Tests ended
Apr 30 16:16:25 :  INFO | testMemPool[139410]/memComponent T=main | main.c _memComponent_COMPONENT_INIT() 639 | TAP | 1..1207
```

**输出解读**：
- `TAP | ok N` - 表示第 N 个测试用例通过
- `TAP | # Tests ended` - 测试完成提示
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

## 2. 事件循环（EventLoop）功能验证

### 2.1 验证目的

验证 Legato 框架事件循环组件的核心功能，包括：
- 事件循环的创建与销毁
- 定时器事件的注册与触发
- 文件描述符监控（FIFO、Socket）
- 事件回调机制
- 事件优先级处理

### 2.2 验证环境

| 项目 | 说明 |
|------|------|
| 目标平台 | localhost（与硬件无关） |
| Legato 版本 | 19.11.0+ |
| 编译命令 | `make localhost` + `make tests_c` |
| 测试应用 | test_EventLoop |

### 2.3 验证步骤

#### 步骤 1：确认测试应用已编译

```bash
# 检查测试应用是否存在
ls -la /home/zhaoming/legato/build/localhost/testFramework/app/test_EventLoop/
```

#### 步骤 2：进入测试目录

```bash
cd /home/zhaoming/legato/build/localhost/testFramework/app/test_EventLoop/staging/read-only/bin/
```

#### 步骤 3：执行测试

```bash
./testEventLoop
```

### 2.4 预期结果

测试应用使用 **TAP（Test Anything Protocol）格式**输出测试结果。正常执行应输出类似以下内容：

```
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c Destructor() 81 | TAP | ok 17 - Reference counted report is now destructed.
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c CheckTestResults() 93 | TAP | ok 18 - Report A successfully passed to queued function.
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c CheckTestResults() 94 | TAP | ok 19 - Report B successfully passed to queued function.
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c CheckTestResults() 96 | TAP | ok 20 - Test Event A passed
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c CheckTestResults() 97 | TAP | ok 21 - Test Event B passed
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c CheckTestResults() 98 | TAP | ok 22 - Test Event C passed
Apr 30 16:22:40 :  INFO | testEventLoop[147163]/eventLoopComponent T=main | eventLoopTest.c CheckTestResults() 100 | ======== EVENT LOOP TEST COMPLETE (PASSED) ========
```

**输出解读**：
- `TAP | ok N` - 表示第 N 个测试用例通过
- `======== EVENT LOOP TEST COMPLETE (PASSED) ========` - 测试完成提示（所有测试通过）

**验证成功标志**：
1. 输出中无 `not ok` 字样（表示无失败测试）
2. 最终输出 `======== EVENT LOOP TEST COMPLETE (PASSED) ========`
3. 无错误日志输出

### 2.5 实际执行命令

```bash
# 完整执行流程
cd /home/zhaoming/legato/build/localhost/testFramework/app/test_EventLoop/staging/read-only/bin/
./testEventLoop
```

---

## 3. 定时器（Timer）功能验证

### 3.1 验证目的

验证 Legato 框架定时器组件的核心功能，包括：
- 定时器的创建与销毁
- 单次定时器触发
- 周期性定时器触发
- 定时器取消功能
- 定时器精度验证

### 3.2 验证环境

| 项目 | 说明 |
|------|------|
| 目标平台 | localhost（与硬件无关） |
| Legato 版本 | 19.11.0+ |
| 编译命令 | `make localhost` + `make tests_c` |
| 测试应用 | test_Timer |

### 3.3 验证步骤

#### 步骤 1：确认测试应用已编译

```bash
# 检查测试应用是否存在
ls -la /home/zhaoming/legato/build/localhost/testFramework/app/test_Timer/
```

#### 步骤 2：进入测试目录

```bash
cd /home/zhaoming/legato/build/localhost/testFramework/app/test_Timer/staging/read-only/bin/
```

#### 步骤 3：执行测试

```bash
./testTimer
```

### 3.4 预期结果

测试应用使用 **TAP（Test Anything Protocol）格式**输出测试结果。正常执行应输出类似以下内容：

```
Apr 30 16:28:38 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c AdditionalTests() 314 | TAP | ok 75 - Setting mediumTimer to 4 s
Apr 30 16:28:38 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c VeryShortTimerExpiryHandler() 174 | TAP | ok 76 - very short timer accuracy within tolerance
Apr 30 16:28:41 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c MediumTimerExpiryHandler() 197 | TAP | ok 77 - medium timer accuracy within tolerance
Apr 30 16:28:41 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c MediumTimerExpiryHandler() 210 | TAP | ok 78 - Very short timer expired once (expired 1 times)
Apr 30 16:28:43 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c LongTimerExpiryHandler() 133 | TAP | # 
  ====================================== 
Apr 30 16:28:43 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c LongTimerExpiryHandler() 137 | TAP | ok 79 - timer accuracy within tolerance
Apr 30 16:28:43 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c LongTimerExpiryHandler() 151 | TAP | ok 80 - Medium timer expired once (expired 1 times)
Apr 30 16:28:43 :  INFO | testTimer[152631]/timerComponent T=main | testTimer.c LongTimerExpiryHandler() 155 | TAP | # Tests ended
```

**输出解读**：
- `TAP | ok N` - 表示第 N 个测试用例通过
- `TAP | # Tests ended` - 测试完成提示
- `timer accuracy within tolerance` - 定时器精度在容差范围内

**验证成功标志**：
1. 输出中无 `not ok` 字样（表示无失败测试）
2. 最终输出 `TAP | # Tests ended`
3. 无错误日志输出

### 3.5 实际执行命令

```bash
# 完整执行流程
cd /home/zhaoming/legato/build/localhost/testFramework/app/test_Timer/staging/read-only/bin/
./testTimer
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