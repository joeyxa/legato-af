# Legato 框架编译与代码移植分析计划

## 项目概述
- **项目名称**: legato-af (Legato Application Framework)
- **目标**: 成功编译框架并进行代码移植分析
- **环境**: WSL Ubuntu 24.04
- **路径**: /home/zhaoming/legato

## 当前状态分析

### 已发现问题
1. **Python 版本问题**: ifgen 脚本使用 `#!/usr/bin/python2.7`，但 Ubuntu 24.04 已移除 Python 2.7
2. **依赖包问题**: README.md 中的依赖包名称需要更新（python → python3）
3. **3rdParty 组件缺失**: Kconfiglib 和 plantuml 需要手动安装

### 已完成的修复
- ✅ 修改 README.md 中的 Python 包依赖（python → python3）
- ✅ 克隆 Kconfiglib 到 3rdParty/Kconfiglib
- ✅ 下载 plantuml.jar 到 3rdParty/plantuml/
- ✅ 创建 platformAdaptor 目录
- ✅ 修改 ifgen 脚本使用 Python 3（`#!/usr/bin/python3`）

---

## 实施步骤

### 阶段一：环境准备与依赖修复

#### 1.1 验证 Python 3 环境
```bash
# 检查 Python 3 版本
python3 --version

# 检查 Python 3 模块
python3 -c "import jinja2; print('jinja2 OK')"
python3 -c "import git; print('git OK')"
```

#### 1.2 安装缺失的 Python 3 依赖
```bash
sudo apt-get install -y python3-jinja2 python3-git python3-pkg-resources
```

#### 1.3 验证 ifgen 脚本修改
```bash
# 检查 ifgen 脚本第一行
head -1 framework/tools/ifgen/ifgen
# 预期输出: #!/usr/bin/python3 -E

# 测试 ifgen 是否可以执行
ifgen --version
```

### 阶段二：编译 Legato 框架

#### 2.1 清理之前的构建
```bash
make clean
```

#### 2.2 执行完整构建
```bash
make
```

#### 2.3 处理可能的编译错误
- 监控编译输出
- 记录所有错误信息
- 针对性修复问题

### 阶段三：代码移植分析

#### 3.1 框架架构分析
- **目录结构分析**
  - framework/: 核心框架代码
  - interfaces/: API 接口定义
  - platformAdaptor/: 平台适配层
  - 3rdParty/: 第三方依赖

#### 3.2 关键组件识别
- **核心库**: liblegato
- **守护进程**: supervisor, serviceDirectory 等
- **工具链**: mk*, ifgen 等
- **平台适配**: 需要移植的硬件相关代码

#### 3.3 移植要点分析
- 平台特定的实现位置
- 硬件抽象层接口
- 编译系统配置
- 依赖库替换方案

### 阶段四：验证与测试

#### 4.1 编译产物验证
```bash
# 检查生成的二进制文件
ls -la build/localhost/framework/bin/

# 检查工具链
ls -la bin/
```

#### 4.2 基础功能测试
```bash
# 测试工具链
mk --version
ifgen --version
```

---

## 风险与应对措施

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| Python 2 到 3 的兼容性问题 | 高 | 全面测试 ifgen 功能，必要时修复 Python 3 兼容性问题 |
| 依赖库版本不兼容 | 中 | 记录所有依赖版本，测试关键功能 |
| 平台特定代码编译失败 | 中 | 分析错误，可能需要条件编译或代码修改 |
| 构建系统配置问题 | 低 | 检查 Makefile 和 ninja 配置 |

---

## 预期产出

1. **成功编译的 Legato 框架**
   - 完整的 build/ 目录
   - 可用的工具链（bin/ 目录）

2. **代码移植分析报告**
   - 架构概述
   - 移植要点清单
   - 平台适配建议

3. **问题修复记录**
   - 所有修复的详细记录
   - 遇到的问题及解决方案

---

## 下一步行动

等待用户确认计划后，立即开始实施阶段一：环境准备与依赖修复。
