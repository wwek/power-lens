下面是一份完整 PRD，定位为**开源 macOS 电池省电分析工具**，后续可扩展到性能分析、电池健康与电池管理。

# macOS 开源省电分析工具 PRD

## 1. 产品名称

暂定名称：

**Power Lens**

中文名：

**功耗雷达 / Mac 省电管家 / 电池侦探**

推荐最终名称：

**Power Lens**

一句话定位：

> Power Lens 是一个开源 macOS 菜单栏工具，用于自动分析 MacBook 掉电快的原因，识别高耗电 App、后台活跃进程、阻止睡眠行为和常见异常，并给出可执行的省电建议。

英文 README 简介：

> Power Lens is an open-source macOS menu bar app that helps you find what is draining your MacBook battery. It analyzes processes, CPU usage, wakeups, sleep assertions, and common app behaviors, then explains the likely cause and suggests safe actions.

---

# 2. 产品背景

## 2.1 问题背景

MacBook 用户经常遇到以下问题：

1. 电池掉电很快，但不知道原因。
2. 活动监视器能看到 CPU、能耗，但普通用户难以理解。
3. Stats、iStat Menus 这类工具偏“监控”，不负责解释原因。
4. App Tamer 可限制后台进程，但不是开源，且更偏进程控制。
5. AlDente 关注充电上限和电池寿命，不负责分析耗电 App。
6. 开发者、设计师、重度办公用户经常运行 Chrome、Docker、VS Code、Cursor、微信、网盘、视频会议软件，这些应用可能在后台持续耗电。
7. 用户想知道的不是“CPU 是多少”，而是：
   - 谁在耗电？
   - 为什么耗电？
   - 我该怎么处理？
   - 这是正常现象还是异常？

因此，本项目希望做一个**开源、透明、本地化、可解释的 macOS 省电分析工具**。

---

# 3. 产品目标

## 3.1 核心目标

帮助用户解决：

> 我的 MacBook 为什么掉电这么快？

产品需要完成一个最小闭环：

1. 用户感觉电池不耐用。
2. 打开 Power Lens。
3. 看到当前是否处于高耗电状态。
4. 看到 Top 高耗电 App。
5. 看到每个 App 的耗电原因。
6. 获得可执行建议。
7. 处理后续航改善。

## 3.2 非目标

MVP 阶段不做以下内容：

1. 不做大型系统监控面板。
2. 不追求精确瓦特级功耗计算。
3. 不自动杀进程。
4. 不默认修改系统设置。
5. 不上传用户隐私数据。
6. 不做云同步。
7. 不做 AI 诊断。
8. 不做完整的充电上限控制。
9. 不做类似 CleanMyMac 的清理工具。
10. 不做杀毒、安全管家。

---

# 4. 产品定位

## 4.1 核心定位

Power Lens 不是传统监控工具，而是：

> macOS 电池耗电诊断工具。

它重点解决：

| 传统工具      | Power Lens               |
| ------------- | ------------------------ |
| 显示 CPU 数字 | 解释为什么耗电           |
| 显示进程列表  | 聚合成 App 级别          |
| 用户自己判断  | 系统自动给出嫌疑排序     |
| 只看当前状态  | 记录一段时间内的耗电事件 |
| 只显示数据    | 给出处理建议             |

## 4.2 差异化

核心差异化：

1. 开源透明。
2. 本地分析，不上传数据。
3. 自动识别耗电嫌疑。
4. 用自然语言解释耗电原因。
5. 给出具体处理建议。
6. 面向 MacBook 电池续航场景。
7. 后续可扩展到性能分析、电池健康、电池管理。

---

# 5. 目标用户

## 5.1 第一目标用户：开发者

典型应用：

- Chrome / Edge
- VS Code
- Cursor
- JetBrains IDE
- Docker Desktop
- Node / Vite / Webpack
- Git 客户端
- 终端
- 本地数据库

典型问题：

- 电池模式下 Docker 还在跑。
- 前端 dev server 持续占用 CPU。
- Cursor / VS Code 插件异常。
- Chrome 标签页过多。
- 后台编译、索引、同步导致掉电。

## 5.2 第二目标用户：重度办公用户

典型应用：

- 微信
- 企业微信
- 飞书
- Slack
- Zoom
- 腾讯会议
- OneDrive
- Dropbox
- iCloud Drive
- WPS / Office

典型问题：

- 会议软件后台没退出。
- 网盘持续同步。
- 微信/企业微信后台持续唤醒。
- 浏览器页面持续播放或刷新。

## 5.3 第三目标用户：普通 MacBook 用户

典型需求：

- 想知道是不是电池坏了。
- 想知道为什么今天特别耗电。
- 想知道要不要开启低电量模式。
- 想知道哪些 App 应该关闭。

---

# 6. 核心使用场景

## 6.1 场景一：用户觉得 MacBook 掉电快

用户打开 Power Lens，看到：

```text
当前状态：高耗电
电池：72%
预计剩余：3h 40m
主要原因：后台 CPU 持续活跃

耗电嫌疑：
1. Google Chrome     82分
2. Docker Desktop    76分
3. 微信              54分
```

点击 Chrome 后看到：

```text
Google Chrome
Power Score: 82 / 100

原因：
- 过去 10 分钟 CPU 持续偏高
- 子进程数量较多
- 后台仍有活跃标签页
- 网络连接活跃

建议：
- 关闭视频、直播、WebGL 页面
- 检查浏览器扩展
- 重启 Chrome
```

## 6.2 场景二：用户合盖后电池仍然下降

Power Lens 检测到 Sleep Assertion：

```text
发现有进程阻止系统休眠：

1. Amphetamine
原因：正在主动保持 Mac 不休眠

2. backupd
原因：Time Machine 备份中

建议：
- 如果你希望 Mac 正常睡眠，请关闭保持唤醒类工具
- 等待 Time Machine 完成备份
```

## 6.3 场景三：开发者使用电池工作

用户打开菜单栏：

```text
当前电池模式下存在开发环境高耗电：

- Docker Desktop 正在运行容器
- node 进程持续活跃
- Cursor 后台 CPU 偏高

建议：
- 暂停非必要容器
- 停止不用的 dev server
- 关闭未使用项目窗口
```

## 6.4 场景四：用户想看最近 24 小时耗电报告

报告页显示：

```text
最近 24 小时耗电摘要：

最常见耗电原因：
1. 浏览器后台活跃
2. Docker 容器运行
3. 网盘同步
4. 系统索引

最耗电 App：
1. Chrome
2. Docker Desktop
3. Cursor
4. 微信
```

---

# 7. 产品结构

## 7.1 MVP 信息架构

```text
Power Lens
├── 菜单栏状态
│   ├── 电池百分比
│   ├── 当前耗电状态
│   ├── Top 耗电 App
│   └── 快速建议
│
├── 耗电诊断页
│   ├── 当前状态
│   ├── 耗电 App 排名
│   ├── 原因标签
│   └── 建议动作
│
├── App 详情页
│   ├── Power Score
│   ├── CPU 趋势
│   ├── 子进程
│   ├── 异常原因
│   └── 建议
│
├── 睡眠阻止检测
│   ├── 阻止睡眠进程
│   ├── 阻止原因
│   └── 处理建议
│
├── 历史事件
│   ├── 高耗电事件
│   ├── App 事件记录
│   └── 24 小时摘要
│
└── 设置
    ├── 采样频率
    ├── 通知开关
    ├── 隐私设置
    ├── 开机启动
    └── 高级模式
```

---

# 8. 功能需求

# 8.1 菜单栏状态

## 8.1.1 功能描述

Power Lens 以 macOS Menu Bar App 形式运行。

菜单栏展示当前电池和耗电状态。

## 8.1.2 显示内容

菜单栏图标状态：

| 状态     | 图标含义                   |
| -------- | -------------------------- |
| 正常     | 电池正常                   |
| 中等耗电 | 有轻微耗电进程             |
| 高耗电   | 存在明显耗电进程           |
| 充电中   | 当前连接电源               |
| 低电量   | 电池较低                   |
| 异常     | 有进程阻止睡眠或持续高耗电 |

点击菜单栏后显示：

```text
Power Lens

电池：72%
状态：高耗电
预计剩余：3h 40m
当前主要原因：后台 CPU 活跃

Top 耗电嫌疑：
1. Chrome           82分
2. Docker Desktop   76分
3. 微信             54分

建议：
- 暂停 Docker 容器
- 关闭 Chrome 高耗电标签页
- 开启低电量模式

[打开完整诊断]
[查看历史报告]
[设置]
```

## 8.1.3 验收标准

1. App 启动后出现在菜单栏。
2. 点击菜单栏能看到电池状态。
3. 能展示 Top 3 耗电 App。
4. 能显示当前耗电等级。
5. 不需要打开完整窗口即可看到核心结论。

---

# 8.2 电池状态检测

## 8.2.1 功能描述

检测当前 MacBook 电池状态。

## 8.2.2 采集字段

| 字段                  | 说明               |
| --------------------- | ------------------ |
| batteryPercentage     | 当前电量百分比     |
| isCharging            | 是否充电中         |
| isOnBattery           | 是否使用电池       |
| powerSource           | 当前电源来源       |
| timeRemaining         | 预计剩余时间       |
| isLowPowerModeEnabled | 是否开启低电量模式 |
| batteryHealth         | 电池健康状态       |
| cycleCount            | 循环次数           |
| designCapacity        | 设计容量           |
| maxCapacity           | 当前最大容量       |

## 8.2.3 MVP 范围

MVP 必须支持：

1. 当前电量。
2. 是否充电。
3. 是否使用电池。
4. 预计剩余时间。
5. 是否低电量模式。

MVP 可选支持：

1. 循环次数。
2. 最大容量。
3. 电池健康。
4. 电池温度。

## 8.2.4 验收标准

1. 使用电池时显示电池状态。
2. 连接电源时显示充电状态。
3. 低电量模式开启时能识别。
4. 无电池设备，如 Mac mini，需要提示“不支持电池检测”。

---

# 8.3 耗电进程检测

## 8.3.1 功能描述

采集系统进程数据，识别高耗电进程，并聚合到 App 维度。

## 8.3.2 采集指标

| 指标             | 说明          |
| ---------------- | ------------- |
| pid              | 进程 ID       |
| processName      | 进程名        |
| bundleIdentifier | App Bundle ID |
| appName          | App 名称      |
| cpuUsage         | 当前 CPU 占用 |
| cpuTimeDelta     | CPU 时间增长  |
| memoryUsage      | 内存占用      |
| diskReadBytes    | 磁盘读取      |
| diskWriteBytes   | 磁盘写入      |
| networkRecvBytes | 网络接收      |
| networkSentBytes | 网络发送      |
| processStartTime | 进程启动时间  |
| isBackground     | 是否后台      |
| parentPid        | 父进程        |
| childProcesses   | 子进程列表    |

## 8.3.3 App 聚合

同一个 App 下的多个进程需要聚合。

例如：

```text
Google Chrome
├── Google Chrome
├── Google Chrome Helper
├── Google Chrome Helper Renderer
├── Google Chrome Helper GPU
└── Google Chrome Helper Plugin
```

在用户界面中优先显示为：

```text
Google Chrome    Power Score: 82
```

详情页再展示子进程。

## 8.3.4 识别策略

### 进程到 App 的映射

优先级：

1. 通过 Bundle Identifier 映射。
2. 通过可执行路径映射。
3. 通过父子进程关系映射。
4. 通过规则库映射。
5. 无法识别时显示进程名。

### 常见 App 规则

MVP 内置识别：

| 类型     | App                                             |
| -------- | ----------------------------------------------- |
| 浏览器   | Chrome、Edge、Safari、Firefox                   |
| 开发工具 | VS Code、Cursor、JetBrains、Xcode               |
| 容器     | Docker Desktop、OrbStack、Colima                |
| 通讯     | 微信、企业微信、飞书、Slack、Discord            |
| 会议     | Zoom、腾讯会议、Teams、Google Meet              |
| 云盘     | iCloud、OneDrive、Dropbox、Google Drive、坚果云 |
| 系统     | Spotlight、Time Machine、photoanalysisd         |

## 8.3.5 验收标准

1. 能列出当前 CPU 高的进程。
2. 能把 Chrome Helper 等子进程聚合到 Chrome。
3. 能展示 Top 5 高耗电 App。
4. 每个 App 有 Power Score。
5. 每个 App 有耗电原因标签。

---

# 8.4 Power Score 评分模型

## 8.4.1 功能描述

为每个 App 计算一个 0-100 的耗电嫌疑分数。

Power Score 不等于真实功耗瓦特数，而是一个“耗电嫌疑评分”。

## 8.4.2 评分目标

评分应该回答：

> 这个 App 是否可能是当前掉电快的主要原因？

## 8.4.3 评分指标

```text
Power Score =
CPU 持续占用分
+ CPU 时间增长分
+ 后台活跃分
+ 唤醒频率分
+ 磁盘 I/O 分
+ 网络 I/O 分
+ 阻止睡眠分
+ GPU 使用分
+ 特殊规则分
```

## 8.4.4 MVP 评分权重

| 指标         | 权重 |
| ------------ | ---: |
| CPU 当前占用 |   30 |
| CPU 持续时间 |   20 |
| 后台活跃     |   15 |
| 阻止睡眠     |   20 |
| 磁盘 I/O     |    5 |
| 网络 I/O     |    5 |
| 规则修正     |    5 |

总分上限：100。

## 8.4.5 分级

|   分数 | 等级 | 文案               |
| -----: | ---- | ------------------ |
|   0-29 | 正常 | 当前未发现明显耗电 |
|  30-59 | 中等 | 可能增加耗电       |
|  60-79 | 高   | 明显影响续航       |
| 80-100 | 异常 | 可能是主要耗电原因 |

## 8.4.6 示例

```text
Chrome
CPU 当前占用：22%
过去 10 分钟平均 CPU：18%
后台活跃：是
网络活跃：是
阻止睡眠：否

Power Score: 76
原因标签：
- High CPU
- Background Active
- Network Active
```

## 8.4.7 验收标准

1. 每个 App 有 0-100 分。
2. 分数能随采样数据变化。
3. CPU 长时间高占用比瞬时高占用分数更高。
4. 阻止睡眠的进程必须明显加分。
5. 前台活跃 App 不应被简单判定为异常，文案应区分“正在使用导致耗电”和“后台异常耗电”。

---

# 8.5 耗电原因标签

## 8.5.1 功能描述

为每个高耗电 App 生成原因标签。

## 8.5.2 标签列表

| 标签                  | 中文说明         |
| --------------------- | ---------------- |
| High CPU              | CPU 占用高       |
| Sustained CPU         | CPU 持续活跃     |
| Background Active     | 后台仍在运行     |
| Preventing Sleep      | 阻止系统睡眠     |
| Network Active        | 网络活动频繁     |
| Disk Busy             | 磁盘读写频繁     |
| Many Child Processes  | 子进程较多       |
| Developer Tool Active | 开发工具活跃     |
| Browser Tab Active    | 浏览器标签页活跃 |
| Syncing Files         | 文件同步中       |
| Indexing              | 系统索引中       |
| Backup Running        | 备份中           |
| Meeting Active        | 会议软件活跃     |
| Media Playing         | 音视频播放中     |
| Unknown Cause         | 原因未知         |

## 8.5.3 文案示例

```text
Google Chrome 当前耗电较高，主要原因是 CPU 持续占用较高，并且后台仍有活跃子进程。常见原因包括视频页面、直播页面、WebGL 页面、开发者工具或浏览器扩展。
```

```text
Docker Desktop 当前在电池模式下仍然活跃，可能是容器、数据库或后台服务持续运行导致。建议暂停不需要的容器。
```

## 8.5.4 验收标准

1. Top 耗电 App 必须有至少一个原因标签。
2. 标签需要对应可解释文案。
3. 标签不能只显示英文，需要有中文说明。
4. 无法判断时显示“原因未知”，不能编造原因。

---

# 8.6 建议系统

## 8.6.1 功能描述

根据 App 类型和耗电原因给出建议。

## 8.6.2 建议类型

| 类型         | 示例                            |
| ------------ | ------------------------------- |
| 安全建议     | 关闭未使用窗口、等待任务完成    |
| 手动操作     | 打开活动监视器、退出 App        |
| 系统设置     | 开启低电量模式、降低亮度        |
| App 特定建议 | 暂停 Docker、关闭 Chrome 标签页 |
| 开发者建议   | 停止 dev server、暂停容器       |
| 电池建议     | 检查电池健康、避免长期满电      |

## 8.6.3 常见建议规则

### Chrome / Edge

触发条件：

- CPU 高。
- 子进程多。
- 后台活跃。

建议：

```text
- 关闭视频、直播、WebGL 页面
- 检查浏览器扩展
- 关闭不用的标签页
- 重启浏览器
```

### Docker Desktop

触发条件：

- 电池模式下 Docker 活跃。
- CPU 或磁盘 I/O 高。

建议：

```text
- 暂停非必要容器
- 停止本地数据库或后台服务
- 在电池模式下退出 Docker Desktop
```

### VS Code / Cursor

触发条件：

- 后台 CPU 高。
- 子进程 node/esbuild/tsserver 活跃。

建议：

```text
- 停止不用的 dev server
- 关闭未使用项目窗口
- 检查插件是否异常
- 重启编辑器
```

### Spotlight

触发条件：

- mds / mds_stores 高 CPU 或高磁盘。

建议：

```text
- Spotlight 正在索引，短时间内属于正常现象
- 如果持续很久，可考虑排除大目录
```

### Time Machine

触发条件：

- backupd 活跃。

建议：

```text
- Time Machine 正在备份
- 如果你正在使用电池，可考虑稍后备份
```

### 微信 / 企业微信 / 飞书

触发条件：

- 后台 CPU 或网络活跃。

建议：

```text
- 如果暂时不用，可退出或关闭后台窗口
- 检查是否有文件传输、视频会议或大量消息同步
```

## 8.6.4 验收标准

1. 每个高耗电 App 至少给出一条建议。
2. 建议必须安全，不默认鼓励强制结束系统进程。
3. 系统进程建议要谨慎，避免误导用户。
4. 建议要区分“正常任务”和“异常耗电”。

---

# 8.7 睡眠阻止检测

## 8.7.1 功能描述

检测哪些进程正在阻止 macOS 睡眠。

## 8.7.2 检测对象

通过系统 Sleep Assertions 获取：

| 类型                        | 说明             |
| --------------------------- | ---------------- |
| PreventUserIdleSystemSleep  | 阻止系统空闲睡眠 |
| PreventUserIdleDisplaySleep | 阻止显示器睡眠   |
| NoDisplaySleepAssertion     | 阻止显示睡眠     |
| BackgroundTask              | 后台任务         |
| UserIsActive                | 用户活跃         |

## 8.7.3 展示示例

```text
发现 2 个进程正在阻止睡眠：

1. Amphetamine
原因：主动保持 Mac 不休眠
建议：如果你希望省电，请关闭保持唤醒模式

2. backupd
原因：Time Machine 正在备份
建议：等待备份完成，或在电池模式下暂停备份
```

## 8.7.4 验收标准

1. 能检测阻止睡眠的进程。
2. 能展示阻止类型。
3. 能映射到 App 名称。
4. 能给出建议。
5. 对常见保持唤醒工具，如 Amphetamine、Caffeine，需要特殊识别。

---

# 8.8 高耗电事件记录

## 8.8.1 功能描述

本地记录最近一段时间的高耗电事件。

## 8.8.2 事件类型

| 事件                  | 说明               |
| --------------------- | ------------------ |
| HighPowerAppDetected  | 检测到高耗电 App   |
| SustainedCPUDetected  | CPU 持续高占用     |
| SleepPrevented        | 发现阻止睡眠       |
| BatteryDrainFast      | 电池下降过快       |
| LowPowerModeSuggested | 建议开启低电量模式 |
| AppReturnedNormal     | App 恢复正常       |

## 8.8.3 事件字段

```json
{
  "id": "event-id",
  "timestamp": "2026-06-04T12:00:00",
  "type": "HighPowerAppDetected",
  "appName": "Google Chrome",
  "bundleIdentifier": "com.google.Chrome",
  "powerScore": 82,
  "reasons": ["High CPU", "Background Active"],
  "suggestions": ["Close unused tabs", "Check extensions"]
}
```

## 8.8.4 存储策略

MVP 阶段：

- 本地 SQLite 或 JSON 文件。
- 默认保留最近 7 天。
- 用户可手动清空。
- 不上传云端。

## 8.8.5 验收标准

1. 能记录高耗电事件。
2. 能展示最近 24 小时事件。
3. 能展示最近 7 天简要统计。
4. 用户可以清空历史。
5. 数据只保存在本机。

---

# 8.9 通知提醒

## 8.9.1 功能描述

当检测到明显异常耗电时，通过 macOS 通知提醒用户。

## 8.9.2 通知场景

| 场景                       | 通知                           |
| -------------------------- | ------------------------------ |
| App 后台高耗电超过 10 分钟 | Chrome 正在后台持续耗电        |
| 有进程阻止睡眠超过 15 分钟 | 有 App 正在阻止 Mac 睡眠       |
| 电池下降过快               | 当前耗电较高，续航可能明显缩短 |
| 电池低且耗电高             | 建议开启低电量模式             |
| Docker 电池模式高耗电      | Docker 正在电池模式下运行      |

## 8.9.3 通知文案

```text
Chrome 正在后台持续耗电
过去 10 分钟 CPU 持续偏高，可能影响续航。
```

```text
Docker Desktop 正在电池模式下运行
如果暂时不用容器，暂停 Docker 可延长续航。
```

## 8.9.4 验收标准

1. 用户可开启/关闭通知。
2. 通知不能过于频繁。
3. 同一个 App 的通知需要冷却时间。
4. 默认只通知明显异常，不通知轻微波动。

---

# 8.10 设置页

## 8.10.1 设置项

| 设置项             | 默认值            |
| ------------------ | ----------------- |
| 开机启动           | 关闭              |
| 通知提醒           | 开启              |
| 菜单栏显示内容     | 电池 + 状态       |
| 采样频率           | 5 秒              |
| 历史保留时间       | 7 天              |
| 低电量提醒阈值     | 30%               |
| 高耗电提醒阈值     | Power Score >= 70 |
| 是否启用高级模式   | 关闭              |
| 是否允许命令行采集 | 关闭              |
| 是否匿名上报       | 不支持 / 默认无   |

## 8.10.2 高级模式

高级模式可以启用：

1. 更详细的进程采样。
2. powermetrics 辅助采集。
3. 更高频率采样。
4. 调试日志。
5. 规则调试。

MVP 阶段高级模式可以先隐藏。

---

# 9. 数据采集设计

## 9.1 采集原则

1. 优先使用公开系统 API。
2. 尽量不需要 root 权限。
3. 不采集用户文件内容。
4. 不采集浏览器网页内容。
5. 不采集聊天内容。
6. 不上传数据。
7. 采集结果只用于本地分析。

## 9.2 采集来源

### 系统 API

| 来源                  | 用途                 |
| --------------------- | -------------------- |
| ProcessInfo           | 系统状态、低电量模式 |
| IOKit                 | 电池、电源信息       |
| NSWorkspace           | 当前 App、前台 App   |
| proc_pidinfo          | 进程 CPU、内存、I/O  |
| host_statistics       | 系统资源             |
| IOPMAssertion         | 睡眠阻止             |
| Unified Logging，可选 | 诊断部分系统事件     |

### 命令行，可选

| 命令                | 用途         |
| ------------------- | ------------ |
| pmset -g batt       | 电池状态     |
| pmset -g assertions | 睡眠阻止     |
| ps                  | 进程信息     |
| top                 | CPU 信息     |
| powermetrics        | 高级功耗信息 |
| ioreg               | 电池硬件信息 |

## 9.3 采样周期

MVP 默认：

```text
普通模式：5 秒采样一次
低功耗模式：10 秒采样一次
详情页打开时：2 秒采样一次
历史聚合：1 分钟聚合一次
```

## 9.4 采样策略

为了避免自身耗电，Power Lens 必须控制自己的资源占用：

| 指标     | 要求                 |
| -------- | -------------------- |
| 常驻 CPU | 平均低于 1%          |
| 内存占用 | 小于 100MB           |
| 采样开销 | 可配置               |
| 后台行为 | 不频繁唤醒           |
| 磁盘写入 | 批量写入，不频繁刷盘 |

---

# 10. 隐私与安全

## 10.1 隐私原则

Power Lens 必须明确承诺：

1. 不上传任何数据。
2. 不读取用户文件内容。
3. 不读取浏览器页面内容。
4. 不读取聊天消息内容。
5. 不采集键盘输入。
6. 不做用户行为追踪。
7. 所有分析在本地完成。
8. 开源代码可审计。

## 10.2 可能采集的数据

本地采集：

- App 名称
- 进程名
- CPU 使用情况
- 内存使用情况
- 磁盘 I/O 统计
- 网络 I/O 统计
- 电池状态
- 睡眠阻止状态
- 高耗电事件

不采集：

- 文件名和文件内容
- 浏览器 URL
- 聊天内容
- 剪贴板
- 键盘输入
- 屏幕截图
- 地理位置
- 用户账号信息

## 10.3 权限策略

MVP 尽量不要求：

- 完全磁盘访问
- 辅助功能权限
- 屏幕录制权限
- 输入监控权限

如果后续版本需要权限，必须：

1. 明确说明用途。
2. 用户主动开启。
3. 提供关闭入口。
4. 不影响基础功能运行。

---

# 11. 技术方案

## 11.1 推荐技术栈

```text
语言：Swift
UI：SwiftUI
运行形态：macOS Menu Bar App
数据存储：SQLite / SwiftData / JSON
构建：Xcode
最低系统版本：macOS 13 起步，后续评估 macOS 12
```

## 11.2 架构设计

```text
PowerLens/
├── App/
│   ├── PowerLensApp.swift
│   ├── MenuBar/
│   ├── Windows/
│   └── Settings/
│
├── Core/
│   ├── Battery/
│   ├── ProcessMonitor/
│   ├── PowerScoring/
│   ├── SleepAssertions/
│   ├── RuleEngine/
│   ├── Recommendation/
│   └── EventStore/
│
├── Collectors/
│   ├── BatteryCollector.swift
│   ├── ProcessCollector.swift
│   ├── SleepAssertionCollector.swift
│   ├── NetworkCollector.swift
│   ├── DiskIOCollector.swift
│   └── PowermetricsCollector.swift
│
├── Rules/
│   ├── BrowserRules.swift
│   ├── DockerRules.swift
│   ├── DeveloperToolRules.swift
│   ├── CloudSyncRules.swift
│   ├── SystemRules.swift
│   └── MeetingRules.swift
│
├── Models/
│   ├── AppPowerSnapshot.swift
│   ├── ProcessSnapshot.swift
│   ├── BatterySnapshot.swift
│   ├── PowerEvent.swift
│   └── Recommendation.swift
│
├── Storage/
│   ├── EventStore.swift
│   └── SettingsStore.swift
│
├── Resources/
│   ├── Localizable.strings
│   └── AppRules.json
│
└── Docs/
    ├── PRD.md
    ├── Architecture.md
    ├── Privacy.md
    └── RuleAuthoring.md
```

## 11.3 模块说明

### Battery 模块

职责：

- 获取电池状态。
- 判断是否电池模式。
- 判断低电量模式。
- 估算当前续航状态。

### ProcessMonitor 模块

职责：

- 枚举进程。
- 采集 CPU、内存、I/O。
- 识别父子进程。
- 聚合到 App。

### PowerScoring 模块

职责：

- 根据采样结果计算 Power Score。
- 判断耗电等级。
- 生成原因标签。

### SleepAssertions 模块

职责：

- 检测阻止睡眠进程。
- 映射到 App。
- 生成建议。

### RuleEngine 模块

职责：

- 根据 App 类型和原因标签套用规则。
- 生成解释文案。
- 生成处理建议。

### EventStore 模块

职责：

- 保存高耗电事件。
- 保存历史趋势。
- 提供报告数据。

---

# 12. UI 设计

## 12.1 菜单栏弹窗

```text
┌─────────────────────────────┐
│ Power Lens                  │
│ 电池 72% · 高耗电            │
│ 预计剩余 3h 40m              │
├─────────────────────────────┤
│ 耗电嫌疑                    │
│ 1. Chrome          82  高    │
│ 2. Docker Desktop  76  高    │
│ 3. 微信             54  中    │
├─────────────────────────────┤
│ 建议                        │
│ 暂停 Docker 容器             │
│ 关闭 Chrome 高耗电标签页      │
├─────────────────────────────┤
│ 打开完整诊断                 │
│ 查看历史报告                 │
│ 设置                         │
└─────────────────────────────┘
```

## 12.2 主窗口：诊断页

```text
当前耗电状态：高

你的 Mac 当前耗电偏高，主要原因是后台 CPU 持续活跃。

Top 耗电 App

| App | 分数 | 原因 | 建议 |
|---|---:|---|---|
| Chrome | 82 | CPU 高、后台活跃 | 关闭高耗电标签页 |
| Docker | 76 | 容器运行、磁盘 I/O | 暂停容器 |
| 微信 | 54 | 网络活跃 | 暂时退出 |
```

## 12.3 App 详情页

```text
Google Chrome

Power Score: 82 / 100
等级：高耗电

原因：
- CPU 持续占用较高
- 后台仍有活跃进程
- 子进程数量较多
- 网络连接活跃

建议：
1. 关闭视频、直播、WebGL 页面
2. 检查浏览器扩展
3. 关闭不用的标签页
4. 重启浏览器

子进程：
- Google Chrome Helper Renderer
- Google Chrome Helper GPU
- Google Chrome Helper Plugin
```

## 12.4 历史报告页

```text
最近 24 小时报告

总体状态：
- 高耗电事件：8 次
- 最常见原因：浏览器后台活跃
- 最常见 App：Chrome

耗电排行：
1. Chrome
2. Docker Desktop
3. Cursor
4. 微信

建议：
- 电池模式下减少 Docker 使用
- 关闭不用的浏览器标签页
- 检查 Cursor / VS Code 插件
```

---

# 13. 规则库设计

## 13.1 规则格式

规则可以用 JSON 或 Swift 内置结构定义。

示例：

```json
{
  "id": "browser_high_cpu",
  "appCategory": "browser",
  "conditions": {
    "reasons": ["High CPU", "Background Active"],
    "minPowerScore": 60
  },
  "title": "浏览器后台耗电较高",
  "explanation": "浏览器可能有视频、直播、WebGL 页面、开发者工具或扩展在后台持续运行。",
  "suggestions": [
    "关闭不用的标签页",
    "检查浏览器扩展",
    "关闭视频或直播页面",
    "重启浏览器"
  ]
}
```

## 13.2 内置规则分类

```text
BrowserRules
DockerRules
DeveloperToolRules
CloudSyncRules
MeetingRules
SystemIndexRules
BackupRules
ChatAppRules
MediaRules
UnknownProcessRules
```

## 13.3 规则优先级

优先级：

1. 系统关键进程规则。
2. App 特定规则。
3. App 分类规则。
4. 通用高 CPU 规则。
5. 未知进程规则。

---

# 14. 开源策略

## 14.1 开源协议

推荐：

```text
GPLv3 或 AGPLv3
```

如果希望商业友好：

```text
Apache-2.0
```

建议选择：

```text
GPLv3
```

理由：

- 防止闭源商业软件直接拿去包装。
- 适合开源工具。
- 对用户隐私更有信任感。

如果你希望更多公司采用，可以选 Apache-2.0。

## 14.2 仓库结构

```text
power-lens/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── docs/
│   ├── PRD.md
│   ├── Architecture.md
│   ├── Privacy.md
│   ├── Roadmap.md
│   └── RuleAuthoring.md
├── app/
│   └── PowerLens/
├── assets/
│   ├── icon/
│   └── screenshots/
└── scripts/
```

## 14.3 README 首屏

README 应突出：

```text
Find what drains your MacBook battery.

Power Lens is an open-source macOS menu bar app that explains why your MacBook battery drains fast. It identifies high-power apps, background CPU usage, sleep blockers, and common battery issues, then suggests safe actions.
```

核心卖点：

```text
- Open source
- Local-only analysis
- No telemetry
- App-level power diagnosis
- Sleep blocker detection
- Developer-friendly
- Safe recommendations
```

---

# 15. 版本路线图

## V0.1：MVP 诊断版

目标：

> 让用户能快速知道当前谁在耗电。

功能：

1. 菜单栏常驻。
2. 电池状态显示。
3. 当前耗电等级。
4. Top 5 耗电 App。
5. Power Score。
6. 原因标签。
7. 睡眠阻止检测。
8. 基础建议。
9. 最近 24 小时事件记录。
10. 设置页。

不做：

1. 自动控制。
2. root helper。
3. 充电上限。
4. AI 分析。
5. 云同步。

## V0.2：历史画像版

功能：

1. 最近 7 天趋势。
2. App 级耗电历史。
3. 高耗电事件时间线。
4. 24 小时报告。
5. 更完整规则库。
6. 更多 App 识别。

## V0.3：开发者增强版

功能：

1. Docker 检测增强。
2. Node / Python / Java 进程识别。
3. VS Code / Cursor 插件异常提示。
4. 本地开发服务识别。
5. 电池模式开发建议。

## V0.4：省电动作版

功能：

1. 一键打开活动监视器。
2. 一键退出普通 App。
3. 一键暂停 Docker，需用户确认。
4. 一键执行 Shortcuts。
5. 低电量模式引导。
6. 自定义规则。

## V0.5：电池健康版

功能：

1. 循环次数。
2. 最大容量。
3. 设计容量。
4. 电池健康趋势。
5. 长期插电提醒。
6. 充电习惯建议。

## V0.6：性能分析版

功能：

1. CPU 性能瓶颈。
2. 内存压力。
3. Swap 分析。
4. 磁盘 I/O 分析。
5. 网络异常。
6. 温度和降频提示。
7. App 卡顿原因分析。

---

# 16. MVP 开发任务拆分

## 16.1 第一阶段：基础框架

任务：

1. 创建 SwiftUI macOS 项目。
2. 实现 Menu Bar App。
3. 实现主窗口。
4. 实现设置页。
5. 实现本地配置存储。

交付：

- App 能启动。
- 菜单栏有图标。
- 可打开主窗口。
- 设置能保存。

## 16.2 第二阶段：电池采集

任务：

1. 获取电池百分比。
2. 获取充电状态。
3. 获取电源来源。
4. 获取低电量模式状态。
5. 显示到菜单栏。

交付：

- 菜单栏展示电池状态。
- 电池/充电状态准确变化。

## 16.3 第三阶段：进程采集

任务：

1. 枚举进程。
2. 获取 CPU 占用。
3. 获取内存占用。
4. 获取进程路径。
5. 映射到 App。
6. 聚合子进程。

交付：

- 能显示 Top CPU App。
- Chrome Helper 能聚合到 Chrome。

## 16.4 第四阶段：Power Score

任务：

1. 实现采样窗口。
2. 计算 CPU 当前值。
3. 计算 CPU 持续值。
4. 计算后台活跃。
5. 计算 Power Score。
6. 输出原因标签。

交付：

- 每个 App 有分数。
- 高 CPU App 排名靠前。
- 后台活跃 App 有标签。

## 16.5 第五阶段：睡眠阻止检测

任务：

1. 调用 IOPMAssertion 或 pmset。
2. 解析阻止睡眠进程。
3. 映射到 App。
4. 生成建议。

交付：

- 能识别阻止睡眠的 App。
- 能展示阻止原因。

## 16.6 第六阶段：规则与建议

任务：

1. 实现 RuleEngine。
2. 添加浏览器规则。
3. 添加 Docker 规则。
4. 添加开发工具规则。
5. 添加系统索引规则。
6. 添加云盘规则。
7. 添加会议软件规则。

交付：

- Top App 有解释。
- Top App 有建议。

## 16.7 第七阶段：历史事件

任务：

1. 设计 PowerEvent。
2. 实现本地存储。
3. 记录高耗电事件。
4. 显示最近 24 小时事件。
5. 支持清空历史。

交付：

- 高耗电事件可回看。
- 历史数据不上传。

---

# 17. 验收指标

## 17.1 功能指标

| 指标         | 要求                           |
| ------------ | ------------------------------ |
| 电池状态识别 | 准确                           |
| Top 耗电 App | 能稳定显示                     |
| App 聚合     | Chrome、Docker、VS Code 等正确 |
| Power Score  | 能反映明显耗电                 |
| 睡眠阻止     | 能检测常见场景                 |
| 建议         | 与原因匹配                     |
| 历史事件     | 可查看最近 24 小时             |

## 17.2 性能指标

| 指标     | 要求           |
| -------- | -------------- |
| 自身 CPU | 平均低于 1%    |
| 内存     | 小于 100MB     |
| 启动时间 | 小于 2 秒      |
| 菜单响应 | 小于 300ms     |
| 磁盘写入 | 批量写入       |
| 采样开销 | 不明显影响续航 |

## 17.3 隐私指标

| 指标            | 要求       |
| --------------- | ---------- |
| 数据上传        | 默认无上传 |
| 遥测            | 无         |
| 文件内容读取    | 无         |
| 聊天内容读取    | 无         |
| 浏览器 URL 读取 | MVP 不读取 |
| 本地历史        | 用户可清空 |

---

# 18. 风险与限制

## 18.1 技术风险

### 风险一：macOS 权限限制

部分指标可能需要更高权限。

应对：

- MVP 不强依赖高级指标。
- 高级功能独立开启。
- 权限请求透明。

### 风险二：精确功耗难以计算

App 级真实功耗很难精确。

应对：

- 产品文案使用“耗电嫌疑评分”。
- 不宣称精确瓦特。
- 重点做相对排序和解释。

### 风险三：自身耗电

监控工具本身可能耗电。

应对：

- 控制采样频率。
- 后台低频采样。
- 批量写入。
- 详情页才高频刷新。

### 风险四：误判

高 CPU 不一定异常，比如用户正在编译或渲染。

应对：

- 区分前台和后台。
- 文案使用“可能”。
- 给出原因和证据。
- 不自动处理。

## 18.2 产品风险

### 风险一：和 Stats/iStat Menus 重叠

应对：

- 不做全量监控。
- 主打“诊断 + 解释 + 建议”。

### 风险二：和 App Tamer 重叠

应对：

- MVP 不做自动限制。
- 主打开源和解释。
- 后续可提供用户确认后的操作。

### 风险三：普通用户理解困难

应对：

- 减少技术术语。
- 使用“谁耗电、为什么、怎么办”的结构。
- 高级数据放在详情页。

---

# 19. 成功标准

## 19.1 MVP 成功标准

MVP 成功的判断：

1. 用户打开后 5 秒内知道当前是否耗电异常。
2. 用户能看到 Top 3 耗电嫌疑。
3. 用户能理解每个嫌疑的原因。
4. 用户能获得至少一条有效建议。
5. 工具自身资源占用低。
6. 开源用户愿意 Star 和反馈规则。

## 19.2 开源社区指标

| 指标        | 目标                |
| ----------- | ------------------- |
| GitHub Star | 首月 100+           |
| Issue 反馈  | 首月 20+            |
| 规则贡献    | 有用户提交 App 规则 |
| 下载使用    | 有真实用户反馈      |
| 隐私信任    | README 明确本地分析 |

---

# 20. 后续扩展方向

## 20.1 性能分析

扩展为：

```text
Mac Power & Performance Doctor
```

新增：

- CPU 瓶颈分析。
- 内存压力分析。
- Swap 分析。
- 温度墙分析。
- 风扇异常。
- 磁盘 I/O 异常。
- 网络异常。
- App 卡顿分析。

## 20.2 电池管理

新增：

- 电池健康趋势。
- 循环次数。
- 充电习惯。
- 长期插电提醒。
- 充电上限控制。
- 电池校准建议。
- 电池老化报告。

## 20.3 规则市场

开源社区可以贡献规则：

```text
rules/
├── browsers.json
├── docker.json
├── developer-tools.json
├── chat-apps.json
├── cloud-sync.json
└── system.json
```

用户可以贡献：

- App 识别规则。
- 原因解释。
- 建议文案。
- 特定国家/地区软件规则。

## 20.4 AI 诊断，可选

后续可做本地 AI 或可选 AI：

- 根据历史事件生成诊断报告。
- 帮用户解释耗电模式。
- 生成个性化省电建议。

但必须保持：

- 默认关闭。
- 用户主动启用。
- 不上传敏感数据。
- 开源透明。

---

# 21. 第一版推荐实现范围

## 必做

```text
1. Menu Bar App
2. 电池状态
3. 当前耗电等级
4. 进程采集
5. App 聚合
6. Top 5 耗电 App
7. Power Score
8. 原因标签
9. 基础建议
10. 睡眠阻止检测
11. 最近 24 小时事件
12. 设置页
13. 隐私说明
```

## 可选

```text
1. 电池循环次数
2. 电池最大容量
3. App 详情趋势图
4. 通知提醒
5. JSON 规则配置
```

## 暂不做

```text
1. 自动杀进程
2. 自动暂停 App
3. 充电上限控制
4. root helper
5. AI 分析
6. 云同步
7. 浏览器标签页级分析
8. 完整系统监控面板
```

---

# 22. 结论

Power Lens 的核心价值不是“显示更多数据”，而是：

> 自动找出 MacBook 掉电快的原因，并告诉用户为什么、怎么办。

第一版只要做好三件事，就有价值：

1. 找出耗电 App。
2. 解释耗电原因。
3. 给出安全建议。

后续再扩展到性能分析和电池管理，产品路线会比较自然。

最终产品方向：

```text
V0.1：省电诊断
V0.2：耗电历史
V0.3：开发者场景增强
V0.4：安全省电动作
V0.5：电池健康
V0.6：性能分析
```

长期定位：

> 开源的 macOS 电池与性能诊断工具。

这个 PRD 可以直接作为 `docs/PRD.md` 放进仓库。我的建议是第一版项目名先用 **Power Lens**，定位清晰，英文也比较适合开源传播。
