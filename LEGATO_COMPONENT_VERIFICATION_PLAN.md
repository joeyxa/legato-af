# Legato 基础组件功能验证计划

## 1. 概述

本计划旨在对 Legato 框架的基础组件进行系统化的功能验证，确保各核心组件的正确性、稳定性和可靠性。验证范围涵盖线程管理、内存管理、同步机制、I/O操作、IPC通信等关键模块。

---

## 2. 基础组件功能清单及验证优先级

### 2.1 核心组件分类

| 优先级 | 组件类别 | 组件名称 | 头文件 | 重要性 |
|:---:|:---:|:---:|:---:|:---:|
| P0 | 线程管理 | Thread | `le_thread.h` | 关键 |
| P0 | 内存管理 | Memory Pool | `le_mem.h` | 关键 |
| P0 | 同步机制 | Mutex | `le_mutex.h` | 关键 |
| P0 | 同步机制 | Semaphore | `le_semaphore.h` | 关键 |
| P0 | IPC通信 | Messaging | `le_messaging.h` | 关键 |
| P1 | 事件处理 | Event Loop | `le_eventLoop.h` | 重要 |
| P1 | 定时器 | Timer | `le_timer.h` | 重要 |
| P1 | 文件系统 | File System | `le_fs.h` | 重要 |
| P1 | 日志系统 | Log | `le_log.h` | 重要 |
| P2 | 数据结构 | Hashmap | `le_hashmap.h` | 中等 |
| P2 | 数据结构 | RedBlackTree | `le_redBlackTree.h` | 中等 |
| P2 | 数据结构 | LinkedList | `le_doublyLinkedList.h` | 中等 |
| P2 | 安全引用 | SafeRef | `le_safeRef.h` | 中等 |
| P2 | 终端I/O | TTY | `le_tty.h` | 中等 |
| P3 | 工具函数 | CRC | `le_crc.h` | 低 |
| P3 | 工具函数 | Base64 | `le_base64.h` | 低 |
| P3 | 工具函数 | UTF-8 | `le_utf8.h` | 低 |
| P3 | 工具函数 | Pack | `le_pack.h` | 低 |

### 2.2 优先级定义

- **P0 (关键)**: 系统核心组件，任何故障将导致系统崩溃或严重功能失效
- **P1 (重要)**: 重要功能组件，故障将影响多个上层应用
- **P2 (中等)**: 常用工具组件，故障影响范围有限
- **P3 (低)**: 辅助工具函数，故障影响较小

---

## 3. 详细验证步骤

### 3.1 P0 级组件验证

#### 3.1.1 线程管理 (le_thread.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建线程 | 线程名: "TestThread", 入口函数, 上下文参数 | 返回有效线程引用 | 检查返回值非NULL |
| 设置优先级 | 线程引用, LE_THREAD_PRIORITY_HIGH | LE_OK | 调用 le_thread_SetPriority() |
| 设置栈大小 | 线程引用, 8192 | LE_OK | 调用 le_thread_SetStackSize() |
| 设置可连接 | 线程引用 | 无返回值 | 调用 le_thread_SetJoinable() |
| 启动线程 | 线程引用 | 无返回值 | 线程执行入口函数 |
| 连接线程 | 线程引用, 结果指针 | LE_OK | 等待线程结束并获取结果 |
| 获取当前线程 | 无 | 当前线程引用 | 调用 le_thread_GetCurrent() |
| 获取线程名称 | 线程引用, 缓冲区, 大小 | 线程名字符串 | 验证名称正确性 |
| 添加析构函数 | 线程引用, 析构函数, 上下文 | 析构函数引用 | 线程退出时调用析构函数 |
| 取消线程 | 线程引用 | LE_OK | 异步终止线程 |
| 线程睡眠 | 1秒 | 返回0 | 验证时间准确性 |

#### 3.1.2 内存池管理 (le_mem.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建内存池 | 池名: "TestPool", 对象大小: 64 | 返回有效池引用 | 检查返回值非NULL |
| 扩展内存池 | 池引用, 10个对象 | 返回池引用 | 调用 le_mem_ExpandPool() |
| 尝试分配 | 池引用 | 非NULL指针或NULL | 调用 le_mem_TryAlloc() |
| 强制分配 | 池引用 | 非NULL指针 | 调用 le_mem_ForceAlloc() |
| 断言分配 | 池引用 | 非NULL指针或进程终止 | 调用 le_mem_AssertAlloc() |
| 释放对象 | 已分配对象指针 | 无返回值 | 调用 le_mem_Release() |
| 引用计数增加 | 对象指针 | 引用计数+1 | 调用 le_mem_AddRef() |
| 获取引用计数 | 对象指针 | 当前引用计数值 | 调用 le_mem_GetRefCount() |
| 设置析构函数 | 池引用, 析构函数 | 无返回值 | 对象释放时调用析构函数 |
| 获取池统计 | 池引用 | 统计结构体 | 调用 le_mem_GetStats() |
| 创建子池 | 父池引用, 5个对象 | 子池引用 | 调用 le_mem_CreateSubPool() |
| 删除子池 | 子池引用 | 无返回值 | 调用 le_mem_DeleteSubPool() |

#### 3.1.3 互斥锁 (le_mutex.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建互斥锁 | 锁名: "TestMutex" | 返回有效锁引用 | 检查返回值非NULL |
| 获取锁 | 锁引用 | LE_OK | 调用 le_mutex_Lock() |
| 尝试获取锁 | 锁引用 | LE_OK 或 LE_WOULD_BLOCK | 调用 le_mutex_TryLock() |
| 释放锁 | 锁引用 | LE_OK | 调用 le_mutex_Unlock() |
| 销毁锁 | 锁引用 | LE_OK | 调用 le_mutex_Destroy() |

#### 3.1.4 信号量 (le_semaphore.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建信号量 | 信号量名: "TestSem", 初始值: 0 | 返回有效信号量引用 | 检查返回值非NULL |
| 等待信号量 | 信号量引用 | LE_OK | 调用 le_semaphore_Wait() |
| 尝试等待 | 信号量引用 | LE_OK 或 LE_WOULD_BLOCK | 调用 le_semaphore_TryWait() |
| 发布信号量 | 信号量引用 | LE_OK | 调用 le_semaphore_Post() |
| 获取值 | 信号量引用 | 当前计数值 | 调用 le_semaphore_GetValue() |
| 销毁信号量 | 信号量引用 | LE_OK | 调用 le_semaphore_Destroy() |

#### 3.1.5 消息传递 (le_messaging.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建消息路由 | 路由名: "TestRoute" | 返回有效路由引用 | 检查返回值非NULL |
| 创建消息会话 | 路由引用 | 返回有效会话引用 | 调用 le_msg_CreateSession() |
| 发送消息 | 会话引用, 消息数据 | LE_OK | 调用 le_msg_Send() |
| 接收消息 | 会话引用 | 接收到的消息 | 调用 le_msg_Receive() |
| 回复消息 | 消息引用, 回复数据 | LE_OK | 调用 le_msg_Reply() |
| 释放消息 | 消息引用 | LE_OK | 调用 le_msg_ReleaseMsg() |
| 销毁会话 | 会话引用 | LE_OK | 调用 le_msg_DestroySession() |

### 3.2 P1 级组件验证

#### 3.2.1 事件循环 (le_eventLoop.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 运行事件循环 | 无 | 阻塞直到退出 | 调用 le_eventLoop_Run() |
| 退出事件循环 | 无 | 事件循环终止 | 调用 le_eventLoop_Quit() |
| 添加文件描述符监听器 | 文件描述符, 事件掩码, 回调函数 | 监听器引用 | 调用 le_fdMonitor_AddFd() |
| 移除文件描述符监听器 | 监听器引用 | LE_OK | 调用 le_fdMonitor_RemoveFd() |

#### 3.2.2 定时器 (le_timer.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建定时器 | 定时器名: "TestTimer" | 返回有效定时器引用 | 检查返回值非NULL |
| 设置定时器周期 | 定时器引用, 1秒 | LE_OK | 调用 le_timer_SetMsInterval() |
| 设置定时器回调 | 定时器引用, 回调函数, 上下文 | LE_OK | 调用 le_timer_SetHandler() |
| 启动定时器 | 定时器引用 | LE_OK | 调用 le_timer_Start() |
| 停止定时器 | 定时器引用 | LE_OK | 调用 le_timer_Stop() |
| 删除定时器 | 定时器引用 | LE_OK | 调用 le_timer_Delete() |

#### 3.2.3 文件系统 (le_fs.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建目录 | 路径: "/tmp/testdir" | LE_OK | 调用 le_dir_Make() |
| 删除目录 | 路径: "/tmp/testdir" | LE_OK | 调用 le_dir_Remove() |
| 打开文件 | 路径: "/tmp/testfile", 标志: O_RDWR | 文件描述符 >= 0 | 调用 le_fs_Open() |
| 读取文件 | 文件描述符, 缓冲区, 大小 | 读取字节数 | 调用 le_fs_Read() |
| 写入文件 | 文件描述符, 数据, 大小 | 写入字节数 | 调用 le_fs_Write() |
| 关闭文件 | 文件描述符 | LE_OK | 调用 le_fs_Close() |
| 删除文件 | 路径: "/tmp/testfile" | LE_OK | 调用 le_fs_Delete() |

#### 3.2.4 日志系统 (le_log.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建日志会话 | 会话名: "TestLog" | 返回有效会话引用 | 调用 le_log_CreateSession() |
| 输出调试日志 | 会话引用, "Debug message" | 日志输出到系统日志 | 调用 LE_DEBUG() |
| 输出信息日志 | 会话引用, "Info message" | 日志输出到系统日志 | 调用 LE_INFO() |
| 输出警告日志 | 会话引用, "Warning message" | 日志输出到系统日志 | 调用 LE_WARN() |
| 输出错误日志 | 会话引用, "Error message" | 日志输出到系统日志 | 调用 LE_ERROR() |

### 3.3 P2 级组件验证

#### 3.3.1 哈希表 (le_hashmap.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建哈希表 | 键大小: 32, 值大小: 64 | 返回有效哈希表引用 | 检查返回值非NULL |
| 插入键值对 | 哈希表引用, 键, 值 | LE_OK | 调用 le_hashmap_Put() |
| 获取值 | 哈希表引用, 键 | 返回对应值 | 调用 le_hashmap_Get() |
| 删除键值对 | 哈希表引用, 键 | LE_OK | 调用 le_hashmap_Remove() |
| 检查键存在 | 哈希表引用, 键 | true/false | 调用 le_hashmap_ContainsKey() |
| 获取键数量 | 哈希表引用 | 键值对数量 | 调用 le_hashmap_GetCount() |
| 销毁哈希表 | 哈希表引用 | LE_OK | 调用 le_hashmap_Destroy() |

#### 3.3.2 安全引用 (le_safeRef.h)

| 测试用例 | 输入参数 | 预期输出 | 验证方法 |
|:---:|:---:|:---:|:---:|
| 创建安全引用映射 | 最大引用数: 100 | 返回有效映射引用 | 检查返回值非NULL |
| 分配引用 | 映射引用, 对象指针 | 引用ID | 调用 le_safeRef_AllocRef() |
| 解析引用 | 映射引用, 引用ID | 对象指针 | 调用 le_safeRef_GetRef() |
| 释放引用 | 映射引用, 引用ID | LE_OK | 调用 le_safeRef_ReleaseRef() |
| 检查引用有效性 | 映射引用, 引用ID | true/false | 调用 le_safeRef_IsValidRef() |

### 3.4 P3 级组件验证

| 组件 | 测试用例 | 验证方法 |
|:---:|:---:|:---:|
| CRC | CRC32计算, CRC16计算 | 验证已知数据的CRC值 |
| Base64 | 编码字符串, 解码Base64 | 验证编码解码一致性 |
| UTF-8 | 字符串长度计算, 字符迭代 | 验证UTF-8处理正确性 |
| Pack | 打包/解包数据结构 | 验证数据完整性 |

---

## 4. 测试环境配置及依赖项

### 4.1 硬件环境

| 配置项 | 要求 |
|:---:|:---:|
| 处理器 | ARM Cortex-A系列或x86_64 |
| 内存 | 至少 256MB RAM |
| 存储 | 至少 512MB 可用空间 |
| 操作系统 | Linux (Ubuntu 18.04+) 或 Legato目标平台 |

### 4.2 软件环境

| 依赖项 | 版本要求 | 用途 |
|:---:|:---:|:---:|
| GCC | 7.5+ | C/C++ 编译器 |
| CMake | 3.10+ | 构建工具 |
| make | 4.0+ | 构建工具 |
| Legato Framework | 当前版本 | 被测框架 |

### 4.3 环境变量配置

```bash
export LEGATO_ROOT=/home/zhaoming/legato
export PATH=$LEGATO_ROOT/bin:$PATH
export LE_CONFIG_DEBUG=1
export LE_CONFIG_LOG_LEVEL=DEBUG
```

### 4.4 编译配置

```bash
cd $LEGATO_ROOT
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -DLE_CONFIG_DEBUG=ON
make -j$(nproc)
```

---

## 5. 风险评估及应对措施

### 5.1 潜在风险清单

| 风险ID | 风险描述 | 严重程度 | 发生概率 | 关联组件 |
|:---:|:---:|:---:|:---:|:---:|
| R01 | 内存池分配失败导致进程崩溃 | 高 | 中 | le_mem |
| R02 | 线程竞态条件导致数据损坏 | 高 | 中 | le_thread, le_mutex |
| R03 | 信号量死锁导致系统挂起 | 高 | 低 | le_semaphore |
| R04 | 消息队列溢出导致消息丢失 | 中 | 中 | le_messaging |
| R05 | 定时器精度不足导致时序问题 | 中 | 中 | le_timer |
| R06 | 文件系统操作失败导致数据丢失 | 中 | 低 | le_fs |
| R07 | 日志系统阻塞导致性能下降 | 低 | 中 | le_log |

### 5.2 应对措施

| 风险ID | 应对措施 |
|:---:|:---|
| R01 | 使用 le_mem_TryAlloc() 替代强制分配，增加内存池监控 |
| R02 | 添加线程安全测试用例，使用线程安全分析工具（如 ThreadSanitizer） |
| R03 | 实现死锁检测机制，设置信号量等待超时 |
| R04 | 监控消息队列深度，实现流量控制 |
| R05 | 使用高精度定时器，验证定时器精度 |
| R06 | 文件操作前检查权限，使用原子文件操作 |
| R07 | 异步日志写入，避免阻塞主线程 |

---

## 6. 验证结果记录格式

### 6.1 测试用例执行记录

| 字段 | 类型 | 说明 |
|:---:|:---:|:---:|
| TestID | 字符串 | 唯一测试用例标识 |
| Component | 字符串 | 被测组件名称 |
| TestName | 字符串 | 测试用例名称 |
| InputParams | JSON | 输入参数 |
| ExpectedOutput | JSON | 预期输出 |
| ActualOutput | JSON | 实际输出 |
| Status | 枚举 | PASS/FAIL/SKIP |
| ErrorMessage | 字符串 | 错误信息（如有） |
| Timestamp | 日期时间 | 测试执行时间 |
| Executor | 字符串 | 测试执行者 |

### 6.2 测试结果汇总表

| 组件 | 测试用例数 | 通过数 | 失败数 | 跳过数 | 通过率 |
|:---:|:---:|:---:|:---:|:---:|:---:|
| le_thread | 11 | - | - | - | - |
| le_mem | 12 | - | - | - | - |
| le_mutex | 5 | - | - | - | - |
| le_semaphore | 6 | - | - | - | - |
| le_messaging | 7 | - | - | - | - |
| le_eventLoop | 4 | - | - | - | - |
| le_timer | 6 | - | - | - | - |
| le_fs | 7 | - | - | - | - |
| le_log | 5 | - | - | - | - |
| le_hashmap | 7 | - | - | - | - |
| le_safeRef | 5 | - | - | - | - |

### 6.3 评估标准

| 评估指标 | 通过标准 |
|:---:|:---:|
| 整体通过率 | >= 95% |
| P0组件通过率 | 100% |
| P1组件通过率 | >= 98% |
| P2组件通过率 | >= 95% |
| P3组件通过率 | >= 90% |
| 无内存泄漏 | Valgrind检测无泄漏 |
| 无线程竞态 | ThreadSanitizer检测无误报 |

---

## 7. 验证执行流程

### 7.1 准备阶段

1. 安装依赖项
2. 配置环境变量
3. 编译Legato框架（Debug模式）
4. 部署测试工具（Valgrind, ThreadSanitizer）

### 7.2 执行阶段

```
┌─────────────────────────────────────────────────────────┐
│                    验证执行流程                         │
├─────────────────────────────────────────────────────────┤
│  1. 运行单元测试                                        │
│     └── 执行各组件的单元测试用例                        │
│                                                         │
│  2. 运行集成测试                                        │
│     └── 验证组件间交互正确性                            │
│                                                         │
│  3. 运行压力测试                                        │
│     └── 高负载场景验证                                  │
│                                                         │
│  4. 运行静态分析                                        │
│     └── 代码质量检查                                    │
│                                                         │
│  5. 运行动态分析                                        │
│     └── Valgrind + ThreadSanitizer                     │
└─────────────────────────────────────────────────────────┘
```

### 7.3 报告阶段

1. 生成测试报告
2. 分析失败用例
3. 提出修复建议
4. 归档验证结果

---

## 8. 附录

### 8.1 测试命令参考

```bash
# 运行所有测试
make test

# 运行特定组件测试
make test-le_thread
make test-le_mem
make test-le_mutex

# 使用Valgrind运行测试
valgrind --leak-check=full ./cxxTest

# 使用ThreadSanitizer运行测试
TSAN_OPTIONS=detect_deadlocks=1 ./cxxTest
```

### 8.2 测试结果归档路径

```
${LEGATO_ROOT}/build/test-results/
├── report.html          # HTML格式测试报告
├── report.xml           # JUnit格式测试报告
├── logs/               # 测试日志目录
│   ├── le_thread.log
│   ├── le_mem.log
│   └── ...
└── artifacts/          # 测试产物
```

---

**文档版本**: v1.0  
**创建日期**: 2024年  
**适用Legato版本**: 当前版本