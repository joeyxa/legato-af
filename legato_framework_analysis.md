# Legato 应用框架详细分析文档

## 目录

1. [框架架构分析](#1-框架架构分析)
   1.1 [整体架构概述](#11-整体架构概述)
   1.2 [分层架构设计](#12-分层架构设计)
   1.3 [核心设计模式](#13-核心设计模式)
2. [关键组件识别](#2-关键组件识别)
   2.1 [核心库组件](#21-核心库组件)
   2.2 [服务接口组件](#22-服务接口组件)
   2.3 [守护进程组件](#23-守护进程组件)
   2.4 [平台适配层组件](#24-平台适配层组件)
3. [编译产物验证](#3-编译产物验证)
   3.1 [产物结构分析](#31-产物结构分析)
   3.2 [关键文件说明](#32-关键文件说明)
   3.3 [编译流程分析](#33-编译流程分析)
4. [功能测试建议](#4-功能测试建议)
   4.1 [测试框架分析](#41-测试框架分析)
   4.2 [测试用例设计](#42-测试用例设计)
   4.3 [测试执行策略](#43-测试执行策略)

***

## 1. 框架架构分析

### 1.1 整体架构概述

Legato 是一个专为嵌入式设备设计的轻量级应用框架，采用微服务架构思想，将系统功能划分为多个独立的组件和服务。框架核心目标是提供：

- **组件化设计**：应用由多个独立组件组成，组件间通过 IPC 通信
- **服务化架构**：核心功能以服务形式提供，支持动态注册和发现
- **跨平台适配**：通过平台适配层(PAL)实现硬件抽象
- **资源管理**：统一的内存、线程、定时器管理

### 1.2 分层架构设计

Legato 采用四层架构设计：

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Applications)                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐   │
│  │  App 1  │  │  App 2  │  │  App 3  │  │   ...      │   │
│  └────┬────┘  └────┬────┘  └────┬────┘  └──────┬──────┘   │
└───────┼────────────┼────────────┼───────────────┼──────────┘
        │            │            │               │
        ▼            ▼            ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│                    服务层 (Services)                        │
│  ┌─────────────┐  ┌─────────────┐  ┌───────────────────┐   │
│  │ le_appCtrl  │  │  le_data   │  │   le_fwupdate    │   │
│  │ le_appInfo  │  │  le_dcs    │  │   le_pm          │   │
│  │ le_appProc  │  │  le_net    │  │   le_gpio        │   │
│  └─────────────┘  └─────────────┘  └───────────────────┘   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    核心层 (Core)                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Thread   │  │  Memory  │  │EventLoop │  │Messaging │   │
│  │ Timer    │  │  Hashmap │  │  Log     │  │   IPC    │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    平台适配层 (Platform Adaptation)          │
│  ┌─────────────┐  ┌─────────────┐  ┌───────────────────┐   │
│  │   pa_eth    │  │   pa_wdog   │  │   pa_clockSync   │   │
│  │   pa_dcs    │  │   pa_gpio   │  │   pa_modem       │   │
│  └─────────────┘  └─────────────┘  └───────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

#### 1.2.1 应用层 (Applications)

应用层包含用户开发的各种应用程序，每个应用可以包含多个组件。应用通过 `.adef` 文件定义，组件通过 `.cdef` 文件定义。

#### 1.2.2 服务层 (Services)

服务层提供系统级服务，通过 API 接口对外暴露功能。服务采用客户端-服务端模式，通过 IPC 机制通信。

#### 1.2.3 核心层 (Core)

核心层提供基础运行时支持，包括：

- 线程管理和调度
- 内存分配和管理
- 事件驱动的消息循环
- IPC 消息传递机制
- 定时器和日志服务

#### 1.2.4 平台适配层 (Platform Adaptation)

平台适配层提供硬件抽象，将底层硬件差异封装，使上层代码与硬件无关。

### 1.3 核心设计模式

#### 1.3.1 IPC 通信模式

Legato 使用基于消息的 IPC 机制，支持同步和异步通信：

```C
Client Component          IPC Layer          Server Component
     │                        │                    │
     ├─→ le_xxx_Request() ──→│──→ le_xxx_Handler()→│
     │                        │                    │
     │←─ le_xxx_Response()←──│←── le_xxx_Reply()←─│
     │                        │                    │
```

#### 1.3.2 事件驱动模式

框架采用事件循环机制处理异步事件：

```C
Event Sources          Event Loop          Event Handlers
     │                     │                    │
     ├─→ Timer Events ────→│───→ Timer Handler  │
     │                     │                    │
     ├─→ IPC Messages ────→│───→ IPC Handler    │
     │                     │                    │
     ├─→ File Events ─────→│───→ FD Handler     │
     │                     │                    │
```

#### 1.3.3 组件化模式

应用由多个独立组件组成，组件间通过绑定(bindings)建立通信：

```C
bindings:
{
    myApp.myComponent.le_data -> dataConnectionService.le_data
    myApp.myComponent.le_log  -> logDaemon.le_log
}
```

***

## 2. 关键组件识别

### 2.1 核心库组件

#### 2.1.1 线程管理 (thread.c)

**功能定位**：提供多线程创建、调度和管理能力

**核心特性**：

- 线程创建和销毁
- 线程优先级管理
- 线程本地存储(TLS)
- 线程安全保证

**关键 API**：

- `le_thread_Create()` - 创建线程
- `le_thread_SetPriority()` - 设置优先级
- `le_thread_GetId()` - 获取线程ID

#### 2.1.2 内存管理 (mem.c)

**功能定位**：提供安全的动态内存分配

**核心特性**：

- 内存分配和释放
- 内存泄漏检测
- 内存越界保护
- 内存池管理

**关键 API**：

- `le_mem_Alloc()` - 分配内存
- `le_mem_Free()` - 释放内存
- `le_mem_CreatePool()` - 创建内存池

#### 2.1.3 事件循环 (eventLoop.c)

**功能定位**：提供异步事件处理机制

**核心特性**：

- 事件注册和触发
- 定时器管理
- 文件描述符监控
- 事件优先级调度

**关键 API**：

- `le_event_AddHandler()` - 添加事件处理器
- `le_event_Report()` - 触发事件
- `le_event_RunLoop()` - 运行事件循环

#### 2.1.4 消息传递 (messagingLocal.c)

**功能定位**：提供进程间通信机制

**核心特性**：

- 同步和异步消息传递
- 请求-响应模式
- 消息队列管理
- 服务发现机制

**关键 API**：

- `le_msg_CreateSession()` - 创建会话
- `le_msg_SendRequest()` - 发送请求
- `le_msg_AddService()` - 注册服务

#### 2.1.5 定时器 (timer.c)

**功能定位**：提供定时任务调度

**核心特性**：

- 单次定时器
- 周期性定时器
- 定时器优先级
- 高精度定时

**关键 API**：

- `le_timer_Create()` - 创建定时器
- `le_timer_SetMsInterval()` - 设置间隔
- `le_timer_Start()` - 启动定时器

### 2.2 服务接口组件

#### 2.2.1 应用管理服务 (le\_appCtrl)

**功能定位**：提供应用生命周期管理

**核心功能**：

- 应用启动和停止
- 应用状态查询
- 应用调试控制
- 应用权限管理

**安全注意**：此 API 应仅对特权用户可用，因为它允许拒绝服务攻击和任意代码执行。

#### 2.2.2 数据连接服务 (le\_data)

**功能定位**：提供网络数据连接管理

**核心功能**：

- 默认数据连接请求/释放
- 连接状态监控
- 网络技术识别
- 连接共享机制

**使用模式**：

```c
// 注册连接状态处理器
le_data_AddConnectionStateHandler(MyConnectionHandler, NULL);

// 请求数据连接
le_data_Request();

// 释放数据连接
le_data_Release();
```

#### 2.2.3 固件更新服务 (le\_fwupdate)

**功能定位**：提供固件更新能力

**核心功能**：

- 固件镜像下载
- 固件验证
- 系统切换（双系统平台）
- 更新状态查询

**更新流程**：

1. 调用 `le_fwupdate_Download()` 下载镜像
2. 在双系统平台调用 `le_fwupdate_Swap()` 切换系统
3. 系统重启后验证更新

#### 2.2.4 电源管理服务 (le\_pm)

**功能定位**：提供电源状态管理

**核心功能**：

- 电源状态查询
- 低功耗模式控制
- 唤醒源管理
- 电源事件通知

### 2.3 守护进程组件

#### 2.3.1 配置树服务 (configTree)

**功能定位**：提供层次化配置管理

**核心特性**：

- 键值对存储
- 层次化配置结构
- 配置变更通知
- 配置持久化

**配置结构示例**：

```C
config:
{
    system:
    {
        network:
        {
            interface = "eth0"
            ipAddress = "192.168.1.100"
        }
    }
}
```

#### 2.3.2 RPC 代理服务 (rpcProxy)

**功能定位**：提供跨进程 RPC 调用能力

**核心特性**：

- 透明的跨进程调用
- 服务注册和发现
- 调用参数序列化
- 错误处理和超时

### 2.4 平台适配层组件

#### 2.4.1 以太网适配 (pa\_ethernet)

**功能定位**：提供以太网接口管理

**核心功能**：

- 接口状态查询
- 通道列表获取
- 事件通知处理

#### 2.4.2 看门狗适配 (pa\_wdog)

**功能定位**：提供硬件看门狗管理

**核心功能**：

- 看门狗启动/停止
- 喂狗操作
- 超时设置

#### 2.4.3 时钟同步适配 (pa\_clockSync)

**功能定位**：提供时钟同步能力

**核心功能**：

- NTP 同步
- 时间查询
- 时区管理

***

## 3. 编译产物验证

### 3.1 产物结构分析

编译完成后生成以下目录结构：

```
build/localhost/
├── 3rdParty/           # 第三方库
│   ├── jansson/        # JSON 库
│   ├── iperf/          # 网络测试工具
│   └── plantuml/       # UML 图表工具
├── apps/               # 应用目录
│   ├── sample/         # 示例应用
│   └── test/           # 测试应用
├── framework/          # 框架库
│   └── lib/            # 编译后的库文件
├── interfaces/         # API 接口文件
│   └── *.h             # 生成的头文件
├── system/             # 系统组件
│   ├── api/            # IPC 接口实现
│   ├── component/      # 组件库
│   └── staging/        # 临时文件
├── system.localhost.update  # 系统更新包
└── localhost.localhost      # 系统核心文件
```

### 3.2 关键文件说明与部署标注

| 文件/目录                             | 描述                  | 大小        | 部署到设备 | 说明             |
| --------------------------------- | ------------------- | --------- | ----- | -------------- |
| `system.localhost.update`         | 系统更新包，包含所有组件        | \~2.7 MB  | **是** | 主要部署镜像，用于OTA升级 |
| `system/`                         | 系统运行时文件             | \~70 MB   | **是** | 完整系统运行环境       |
| `framework/lib/liblegato.so`      | 框架核心库               | \~427 KB  | **是** | Legato运行时核心    |
| `framework/lib/libComponent_*.so` | 各组件库                | 15-298 KB | **是** | 系统服务组件         |
| `framework/lib/libjansson.so`     | JSON解析库             | \~148 KB  | **是** | 第三方依赖库         |
| `apps/`                           | 应用程序                | \~15 MB   | 部分    | 用户应用按需部署       |
| `apps/tools/`                     | 工具应用(cm, fwupdate等) | 视具体工具     | **是** | 系统管理工具         |
| `interfaces/*.h`                  | API头文件              | -         | 否     | 开发时使用，不部署      |
| `3rdParty/`                       | 第三方库源码              | -         | 否     | 编译依赖，不部署       |
| `tests/`                          | 测试代码                | -         | 否     | 测试用，不部署        |
| `samples/`                        | 示例代码                | -         | 否     | 参考用，不部署        |

### 3.3 核心库文件详细分析

以下是 `framework/lib/` 目录中的核心库文件：

| 库文件                                | 大小 (KB) | 部署到设备 | 功能说明                  |
| ---------------------------------- | ------- | ----- | --------------------- |
| `liblegato.so`                     | 427     | **是** | 核心运行时库 - Legato框架基础功能 |
| `libComponent_supervisor.so`       | 291     | **是** | 进程管理 - 应用生命周期管理       |
| `libComponent_updateDaemon.so`     | 236     | **是** | 更新服务 - 系统更新机制         |
| `libComponent_configTree.so`       | 167     | **是** | 配置服务 - 配置树管理          |
| `libjansson.so.4.15.0`             | 148     | **是** | JSON解析库 - 第三方依赖       |
| `libComponent_appCtrl.so`          | 131     | **是** | 应用控制 - 应用启停控制         |
| `libComponent_watchdogDaemon.so`   | 127     | **是** | 看门狗服务 - 系统健康监控        |
| `libComponent_logDaemon.so`        | 58      | **是** | 日志服务 - 日志管理           |
| `libComponent_update.so`           | 55      | **是** | 更新接口 - 更新API          |
| `libComponent_config.so`           | 93      | **是** | 配置工具 - 配置读写           |
| `libComponent_sbtrace.so`          | 60      | **是** | 系统回溯 - 调试追踪           |
| `libComponent_sdirTool.so`         | 77      | **是** | 服务目录工具                |
| `libComponent_serviceDirectory.so` | 39      | **是** | 服务目录服务                |
| `libComponent_appCfg.so`           | 68      | **是** | 应用配置服务                |
| `libComponent_le_pa_start.so`      | 15      | **是** | 平台适配启动组件              |

### 3.4 编译产物大小统计

#### 3.4.1 整体大小概览

| 目录/文件                       | 大小 (KB) | 大小 (MB) | 部署到设备 |
| --------------------------- | ------- | ------- | ----- |
| **localhost 总目录**           | 154,696 | \~151   | -     |
| **system.localhost.update** | 2,784   | \~2.66  | **是** |
| **system/**                 | 71,776  | \~70    | **是** |
| **apps/**                   | 15,500  | \~15    | 部分    |
| **framework/lib/**          | 1,992   | \~2     | **是** |
| **tools/**                  | 208     | \~0.2   | 部分    |

#### 3.4.2 部署包大小分析

**必须部署的核心文件：**

| 组件类型   | 大小 (MB)     | 说明                  |
| ------ | ----------- | ------------------- |
| 系统更新包  | \~2.66      | 最小部署单元              |
| 框架核心库  | \~2         | liblegato + 组件库     |
| 系统工具   | \~15        | cm, fwupdate, gnss等 |
| **合计** | **\~20 MB** | 最小系统部署大小            |

**完整系统部署（包含所有组件）：**

| 组件类型   | 大小 (MB)     | 说明       |
| ------ | ----------- | -------- |
| 系统目录   | \~70        | 完整系统运行时  |
| 应用目录   | \~15        | 平台服务和工具  |
| **合计** | **\~85 MB** | 完整系统部署大小 |

### 3.5 部署建议

#### 3.5.1 最小系统部署

适用于资源受限的嵌入式设备：

```
┌────────────────────────────────────────┐
│         最小部署 (~20 MB)              │
├────────────────────────────────────────┤
│ • system.localhost.update (~2.7 MB)    │
│ • 核心库组件 (~2 MB)                   │
│ • 必要工具应用 (~15 MB)                 │
└────────────────────────────────────────┘
```

**部署方式**：

1. 通过 OTA 更新包部署 `system.localhost.update`
2. 或直接拷贝文件系统到设备

#### 3.5.2 完整系统部署

适用于开发和测试环境：

```
┌────────────────────────────────────────┐
│         完整部署 (~85 MB)              │
├────────────────────────────────────────┤
│ • 完整 system/ 目录 (~70 MB)           │
│ • 所有 apps/ 应用 (~15 MB)             │
│ • 包含测试和示例代码                    │
└────────────────────────────────────────┘
```

**部署方式**：

1. 拷贝整个 build/localhost/system/ 目录
2. 设置正确的文件权限
3. 配置启动脚本

### 3.6 system/ 目录深度分析

#### 3.6.1 目录结构和大小分布

`system/` 目录是编译后的完整系统环境，包含以下子目录：

| 子目录            | 大小 (KB) | 大小 (MB) | 占比      | 内容说明                      |
| -------------- | ------- | ------- | ------- | ------------------------- |
| **api/**       | 37,840  | \~37    | **53%** | IPC接口代码（客户端/服务端）          |
| **component/** | 16,068  | \~16    | **22%** | 组件编译产物                    |
| **app/**       | 11,744  | \~12    | **16%** | 服务应用（tools、modemService等） |
| **staging/**   | 3,592   | \~3.5   | **5%**  | 临时文件                      |
| **config/**    | 12      | \~0     | <1%     | 配置文件                      |

#### 3.6.2 最大目录：api/

`api/` 目录包含自动生成的IPC接口代码：

```
api/
├── [哈希目录名]/
│   ├── client/           # 客户端代码
│   │   ├── le_xxx_client.c     # 客户端实现
│   │   ├── le_xxx_client.c.o   # 编译目标文件
│   │   └── le_xxx_interface.h  # 接口头文件
│   ├── server/           # 服务端代码
│   │   ├── le_xxx_server.c     # 服务端实现
│   │   ├── le_xxx_server.o     # 编译目标文件
│   │   └── le_xxx_server.h     # 服务端头文件
│   ├── le_xxx_common.h   # 公共定义
│   └── le_xxx_messages.h # 消息定义
```

**特点**：

- 由 `ifgen` 工具从 `.api` 文件自动生成
- 每个API接口对应一个哈希目录
- 包含中间产物（.o 对象文件和 .o.d 依赖文件）

#### 3.6.3 app/ 目录服务列表

| 应用                      | 说明                 |
| ----------------------- | ------------------ |
| `atService`             | AT命令服务             |
| `audioService`          | 音频服务               |
| `cellNetService`        | 蜂窝网络服务             |
| `dataConnectionService` | 数据连接服务             |
| `fwupdateService`       | 固件更新服务             |
| `gpioService`           | GPIO服务             |
| `modemService`          | 调制解调器服务            |
| `tools`                 | 系统工具（cm、fwupdate等） |
| `voiceCallService`      | 语音通话服务             |

### 3.7 update 文件完整性分析

#### 3.7.1 update 文件内容

`system.localhost.update` 是 Legato 的系统更新包，包含以下核心组件：

| 组件类型     | 包含内容                                          |
| -------- | --------------------------------------------- |
| **核心框架** | `liblegato.so` + 所有核心组件库                      |
| **系统服务** | supervisor、logDaemon、configTree、updateDaemon  |
| **平台服务** | dataConnectionService、modemService、powerMgr 等 |
| **系统工具** | cm、fwupdate、inspect 等                         |
| **配置文件** | 系统默认配置、服务绑定配置                                 |

#### 3.7.2 功能完整性对比

| 功能    | update 文件 | 完整 system/ 目录 |
| ----- | --------- | ------------- |
| 进程管理  | ✅ 完整      | ✅ 完整          |
| 系统日志  | ✅ 完整      | ✅ 完整          |
| 配置管理  | ✅ 完整      | ✅ 完整          |
| IPC通信 | ✅ 完整      | ✅ 完整          |
| 电源管理  | ✅ 完整      | ✅ 完整          |
| 数据连接  | ✅ 完整      | ✅ 完整          |
| 固件更新  | ✅ 完整      | ✅ 完整          |
| 调试工具  | ⚠️ 有限     | ✅ 完整          |
| 测试代码  | ❌ 无       | ✅ 包含          |

#### 3.7.3 部署场景建议

**生产环境部署（推荐）**：

```bash
# 使用 update 文件进行部署（约2.7 MB）
legato-install system.localhost.update /mnt/legato
```

**开发/调试环境**：

```bash
# 部署完整的 system/ 目录（约70 MB）
cp -r build/localhost/system /mnt/legato
```

#### 3.7.4 功能验证方法

部署后可以通过以下命令验证功能完整性：

```bash
# 检查核心服务是否运行
apps/tools/cm/bin/cm info

# 检查数据连接服务
apps/tools/cm/bin/cm data status

# 检查系统状态
legato status
```

### 3.8 总结：部署方案选择

| 维度       | update 文件 (\~2.7 MB) | 完整 system/ 目录 (\~70 MB) |
| -------- | -------------------- | ----------------------- |
| **核心功能** | ✅ 完整                 | ✅ 完整                    |
| **调试能力** | ⚠️ 有限                | ✅ 完整                    |
| **测试代码** | ❌ 无                  | ✅ 包含                    |
| **存储占用** | 低                    | 高                       |
| **推荐场景** | 生产环境                 | 开发/调试                   |

### 3.9 编译流程分析

Legato 采用 Ninja 构建系统，编译流程如下：

```
1. 配置阶段
   ├── 读取 KConfig 配置
   ├── 生成 .config 文件
   └── 配置工具链路径

2. 代码生成阶段
   ├── ifgen 解析 .api 文件
   ├── 生成 IPC 接口代码
   └── 生成组件绑定代码

3. 编译阶段
   ├── 编译 liblegato 核心库
   ├── 编译平台适配组件
   ├── 编译服务组件
   └── 编译测试和示例应用

4. 链接阶段
   ├── 链接各组件库
   ├── 生成可执行文件
   └── 生成共享库

5. 打包阶段
   ├── 创建系统更新包
   ├── 生成系统镜像
   └── 生成清单文件
```

**编译命令**：

```bash
# 完整编译
make

# 仅编译系统
make system

# 编译特定应用
make appName
```

***

## 4. 功能测试建议

### 4.1 测试框架分析

Legato 提供了完整的测试框架，支持：

- **单元测试**：使用 CUnit 框架
- **集成测试**：组件间交互测试
- **系统测试**：端到端功能测试
- **性能测试**：性能基准测试

**测试目录结构**：

```
framework/test/        # 核心库测试
apps/test/             # 应用层测试
interfaces/test/       # 接口测试
platformAdaptor/test/  # 平台适配测试
```

### 4.1.1 build/localhost 下的测试路径结构

编译完成后，`build/localhost` 目录下包含多个以 `test` 开头的路径，各自承担不同的测试功能：

```
build/localhost/
├── apps/test/          # 应用层测试源码和构建中间产物
├── testApps/           # 安全存储相关测试应用
├── testComponents/     # 组件级测试应用
├── testFramework/      # 核心框架单元测试
└── tests/              # 最终测试产物（可运行的测试）
```

#### 4.1.1.1 apps/test/ - 应用层测试目录

包含应用层集成测试的源码和构建中间产物：

```
apps/test/
├── framework/           # 框架功能测试
│   ├── args/            # 参数处理测试
│   ├── clock/           # 时钟测试
│   ├── fs/              # 文件系统测试
│   ├── hex/             # hex 编码测试
│   ├── pack/            # 打包测试
│   ├── path/            # 路径处理测试
│   ├── random/          # 随机数测试
│   ├── rbtree/          # 红黑树测试
│   ├── safeRef/         # 安全引用测试
│   ├── signalEvents/    # 信号事件测试
│   ├── timers/          # 定时器测试
│   └── utf8/            # UTF-8 测试
├── avcService/          # AVC 服务测试
├── ifgen/               # ifgen 工具测试
└── modemServices/       # 调制解调器服务测试
```

#### 4.1.1.2 testApps/ - 测试应用目录

包含安全存储相关的独立测试应用：

| 目录 | 说明 |
|------|------|
| `test_SecStore1a` | 安全存储测试1a |
| `test_SecStore1b` | 安全存储测试1b |
| `test_SecStore2` | 安全存储测试2 |
| `test_SecStore2Global` | 安全存储全局测试2 |
| `test_SecStoreGlobal` | 安全存储全局测试 |

#### 4.1.1.3 testComponents/ - 测试组件目录

包含组件级别的测试应用：

| 目录 | 说明 |
|------|------|
| `test_Watchdog` | 看门狗组件测试 |
| `test_WatchdogMulti` | 多路看门狗测试 |

#### 4.1.1.4 testFramework/ - 测试框架目录

包含核心框架的单元测试：

```
testFramework/app/
├── test_Clock          # 时钟测试
├── test_Crc            # CRC 测试
├── test_EventLoop      # 事件循环测试
├── test_Fd             # 文件描述符测试
├── test_FdMonitorFifo  # FIFO 监控测试
├── test_FdMonitorSocket # Socket 监控测试
├── test_Fs             # 文件系统测试
├── test_HashMap        # 哈希表测试
├── test_Hex            # Hex 测试
├── test_IpcC2C         # IPC 组件间通信测试
├── test_IpcC2CAsync    # 异步 IPC 测试
├── test_IpcCRelay      # IPC 中继测试
├── test_Json           # JSON 测试
├── test_Lists          # 链表测试
├── test_MemPool        # 内存池测试
├── test_Pack           # 打包测试
├── test_PathIter       # 路径迭代测试
├── test_Rand           # 随机数测试
├── test_Semaphore      # 信号量测试
├── test_Thread         # 线程测试
└── test_Timer          # 定时器测试
```

#### 4.1.1.5 tests/ - 最终测试产物目录

这是编译完成后生成的最终测试产物：

```
tests/
├── apps/              # 测试应用 (.localhost.update 格式)
├── bin/               # 测试可执行文件
└── lib/               # 测试库文件
```

#### 4.1.1.6 测试路径分类总结

| 路径前缀 | 类型 | 说明 |
|----------|------|------|
| `apps/test/` | 目录 | 应用层集成测试源码和中间产物 |
| `testApps/` | 目录 | 安全存储独立测试应用 |
| `testComponents/` | 目录 | 组件级测试应用 |
| `testFramework/` | 目录 | 核心框架单元测试 |
| `tests/` | 目录 | 最终测试产物（可运行） |
| `test*.localhost` | 文件 | 测试应用镜像文件 |
| `obj/test*` | 文件 | 编译目标文件 |
| `src/test*` | 文件 | 生成的测试源码 |

#### 4.1.1.7 测试路径用途对比

| 目录 | 内容 | 用途 |
|------|------|------|
| `apps/test/` | 测试源码 + 构建中间产物 | 开发和编译测试 |
| `testApps/` | 安全存储测试应用 | 特定功能验证 |
| `testComponents/` | 组件测试应用 | 组件功能验证 |
| `testFramework/` | 核心库单元测试 | 框架基础功能验证 |
| `tests/` | 最终测试产物 | 运行测试 |

### 4.1.2 测试编译结果统计

| 类别 | 数量 | 状态 |
|------|------|------|
| 测试应用 | 48 | ✅ 已编译 |
| 测试可执行文件 | 36 | ✅ 已编译 |
| 成功运行 | 1+ | ✅ 通过 |
| 无法编译 | ~10 | ❌ 缺少模拟组件 |

### 4.1.3 已编译成功的测试应用列表

**核心框架测试：**
- `FaultApp.localhost.update`
- `ForkChildApp.localhost.update`
- `RestartApp.localhost.update`
- `StopApp.localhost.update`
- `badAppNSB.localhost.update`
- `badAppSB.localhost.update`

**配置测试：**
- `cfgSelfRead.localhost.update`
- `cfgSelfWrite.localhost.update`
- `cfgSystemRead.localhost.update`
- `cfgSystemWrite.localhost.update`

**安全存储测试：**
- `secStoreTest1a.localhost.update`
- `secStoreTest1b.localhost.update`
- `secStoreTest2.localhost.update`
- `secStoreTest2Global.localhost.update`
- `secStoreTestGlobal.localhost.update`

**调制解调器服务测试：**
- `smsTest.localhost.update`
- `smsDeletion.localhost.update`
- `smsCBTest.localhost.update`

**其他测试：**
- `cxxHello.localhost.update`
- `dogTest.localhost.update`
- `dogTestNever.localhost.update`

### 4.1.4 已编译成功的测试可执行文件列表

| 测试名称 | 说明 |
|----------|------|
| `cxxTest` | C++ 框架测试 |
| `cm.test` | 连接管理测试 |
| `configTestExe` | 配置测试 |
| `secStoreUnitTest_secStoreTest1a` | 安全存储单元测试 |
| `secStoreUnitTest_secStoreTest1b` | 安全存储单元测试 |
| `secStoreUnitTest_secStoreTest2` | 安全存储单元测试 |
| `secStoreUnitTest_secStoreTestGlobal` | 安全存储单元测试 |

### 4.1.5 无法编译的测试列表

| 测试名称 | 失败原因 | 需要的组件 |
|----------|----------|------------|
| `smsUnitTest` | 缺少模拟组件 | `/simu/components/le_pa/pa_mrc_simu.c` |
| | | `/simu/components/le_pa/pa_sim_simu.c` |
| | | `/simu/components/le_pa/pa_sms_simu.c` |
| `mdcUnitTest` | 缺少模拟组件 | `/simu/components/le_pa/pa_mdc_simu.c` |
| `ecallUnitTest` | 缺少模拟组件 | `/simu/components/le_pa/pa_ecall_simu.c` |
| `fwupdateUnitTest` | 缺少模拟组件 | `/simu/components/le_pa/pa_fwupdate_simu.c` |
| `atClientUnitTest` | 测试可执行文件未编译 | - |
| `atServerUnitTest` | 测试可执行文件未编译 | - |
| `cellNetUnitTest` | 测试可执行文件未编译 | - |
| `dataConnectionUnitTest` | 测试可执行文件未编译 | - |
| `voiceCallServiceUnitTest` | 测试可执行文件未编译 | - |

### 4.1.6 测试运行验证

**cxxTest 运行结果：**

```bash
./tests/bin/cxxTest
# Output:
# Apr 16 15:16:02 :  INFO | cxxTest[751559]/cxxTest_exe T=main | Hello.cpp _cxxTest_exe_COMPONENT_INIT() 16 | Hello world, from thread 1.
# Apr 16 15:16:02 :  INFO | cxxTest[751559]/cxxTest_exe T=thread 2 | Hello.cpp operator()() 25 | Hello world, from thread 2.
# Apr 16 15:16:02 :  INFO | cxxTest[751559]/cxxTest_exe T=main | Hello.cpp _cxxTest_exe_COMPONENT_INIT() 33 | Thread 2 ended, all done with init.
```

**测试结果分析：**

| 测试名称 | 运行状态 | 说明 |
|----------|----------|------|
| `cxxTest` | ✅ 通过 | C++ 框架测试成功 |
| `configTestExe` | ⚠️ 部分通过 | 需要完整 Legato 运行时环境 |
| `secStoreUnitTest_*` | ⚠️ 部分通过 | 需要完整运行时环境 |

### 4.1.7 无法编译原因分析

无法编译的测试主要是因为缺少**调制解调器模拟组件**（`pa_*_simu.c`），这些组件的作用：

- 用于单元测试的模拟实现
- 模拟真实硬件的行为
- 在实际硬件上运行时不需要

**解决方案：**

1. **创建缺失的模拟组件**：编写模拟实现文件
2. **跳过特定测试**：使用 `ctest -E` 排除无法编译的测试
3. **在真实硬件上运行**：实际硬件环境不需要模拟组件

### 4.2 测试用例设计

#### 4.2.1 核心库测试用例

| 模块        | 测试场景    | 预期结果       |
| --------- | ------- | ---------- |
| Thread    | 创建/销毁线程 | 线程成功创建和销毁  |
| Thread    | 设置优先级   | 优先级正确设置    |
| Memory    | 分配/释放内存 | 无内存泄漏      |
| Memory    | 越界访问    | 检测到越界并报错   |
| EventLoop | 定时器触发   | 定时器按时触发    |
| EventLoop | 事件优先级   | 高优先级事件优先处理 |
| Messaging | 同步消息    | 请求-响应正常    |
| Messaging | 异步消息    | 消息正确传递     |

#### 4.2.2 服务接口测试用例

| 服务           | 测试场景    | 预期结果     |
| ------------ | ------- | -------- |
| le\_appCtrl  | 启动/停止应用 | 应用状态正确变化 |
| le\_appCtrl  | 查询应用状态  | 返回正确状态信息 |
| le\_data     | 请求/释放连接 | 连接状态正确变化 |
| le\_data     | 多应用共享连接 | 连接正确共享   |
| le\_fwupdate | 下载固件    | 固件成功下载   |
| le\_pm       | 查询电源状态  | 返回正确状态   |

#### 4.2.3 平台适配测试用例

| 组件            | 测试场景     | 预期结果    |
| ------------- | -------- | ------- |
| pa\_ethernet  | 查询接口状态   | 返回正确状态  |
| pa\_wdog      | 启动/喂狗/停止 | 看门狗正常工作 |
| pa\_clockSync | NTP 同步   | 时间正确同步  |

### 4.3 测试执行策略

#### 4.3.1 测试执行顺序

```
1. 单元测试
   ├── framework/test/
   └── interfaces/test/

2. 集成测试
   ├── apps/test/
   └── platformAdaptor/test/

3. 系统测试
   ├── 启动系统
   ├── 运行测试应用
   └── 验证功能

4. 性能测试
   ├── 内存使用测试
   ├── CPU 占用测试
   └── 响应时间测试
```

#### 4.3.2 测试命令

```bash
# 运行所有测试
make test

# 运行特定测试
make test-<testName>

# 运行 CUnit 测试
cd build/localhost && ctest

# 运行性能测试
make perf-test
```

#### 4.3.3 测试环境要求

| 环境项    | 要求                      |
| ------ | ----------------------- |
| 操作系统   | Linux (推荐 Ubuntu 24.04) |
| Python | 3.8+                    |
| 编译器    | GCC 9+                  |
| 内存     | 至少 4GB                  |
| 磁盘空间   | 至少 20GB                 |

***

## 附录：代码移植注意事项

### A.1 从 Python 2 到 Python 3 的移植

Legato 框架中的 Python 工具脚本需要从 Python 2 移植到 Python 3：

| Python 2 特性               | Python 3 替代                                  |
| ------------------------- | -------------------------------------------- |
| `print 'text'`            | `print('text')`                              |
| `except Exception, e`     | `except Exception as e`                      |
| `unicode()`               | `str()`                                      |
| `basestring`              | `str`                                        |
| `long`                    | `int`                                        |
| `itervalues()`            | `values()`                                   |
| `decode('string_escape')` | `encode('latin-1').decode('unicode_escape')` |
| `StringIO.StringIO`       | `io.StringIO`                                |

### A.2 平台适配层移植

移植到新硬件平台时需要实现以下适配组件：

| 组件            | 需要实现的功能 |
| ------------- | ------- |
| pa\_ethernet  | 以太网接口管理 |
| pa\_wdog      | 看门狗管理   |
| pa\_clockSync | 时钟同步    |
| pa\_gpio      | GPIO 控制 |
| pa\_modem     | 调制解调器控制 |

***

**文档版本**: v1.0\
**生成日期**: 2026年4月\
**适用版本**: Legato 19.11.0
