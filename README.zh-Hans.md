<p align="center">
  <img src="PowerLens/Resources/Assets.xcassets/AppIcon.appiconset/app-icon-512.png" alt="Power Lens" width="128" height="128">
</p>

<h1 align="center">Power Lens</h1>

<p align="center"><strong>找出是什么在消耗你的 MacBook 电池。</strong></p>

<p align="center">
  <a href="https://github.com/wwek/power-lens/releases"><img src="https://img.shields.io/github/v/release/wwek/power-lens?display_name=tag&style=flat-square" alt="Release"></a>
  <a href="https://github.com/wwek/power-lens/actions"><img src="https://img.shields.io/github/actions/workflow/status/wwek/power-lens/build.yml?branch=main&style=flat-square" alt="Build"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/license-GPLv3-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Swift-6.2-orange?style=flat-square" alt="Swift">
</p>

<p align="center">
  <a href="README.md">English</a> |
  <a href="README.zh-Hans.md">简体中文</a> |
  <a href="README.zh-Hant.md">繁體中文</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.ko.md">한국어</a>
</p>

---

Power Lens 是一款开源 macOS 菜单栏应用，帮你诊断 MacBook 电池为什么耗电快。它识别高耗电应用、后台 CPU 占用、睡眠阻止项，并给出安全建议。

## 功能特性

- **开源** — 完全透明，社区驱动
- **本地运行** — 所有分析都在你的 Mac 上完成，零数据上传
- **无遥测** — 无跟踪、无分析、无数据上报
- **应用级诊断** — 将进程聚合成应用并评分
- **睡眠阻止检测** — 找出阻止 Mac 睡眠的应用
- **开发者友好** — 识别 Docker、开发服务器、VS Code、Cursor 等
- **安全建议** — 解释原因并建议操作，绝不自动杀进程
- **多语言** — English、简体中文、繁體中文、日本語、한국어

## 系统要求

- macOS 14 Sonoma 或更高版本
- Apple Silicon 或 Intel Mac

## 安装

### 下载安装

从 [Releases](../../releases) 下载最新的 `Power Lens.dmg`。

### Homebrew 安装

```bash
brew install --cask power-lens
```

### 从源码构建

```bash
git clone https://github.com/wwek/power-lens.git
cd power-lens
open PowerLens.xcodeproj
# 按 Cmd+R 构建并运行
```

或通过命令行：

```bash
xcodebuild -project PowerLens.xcodeproj -scheme "Power Lens" -configuration Debug build
```

## 使用方法

1. 点击菜单栏图标查看当前电池状态和耗电等级
2. 查看按耗电评分（0–100）排名的高耗电应用
3. 通过原因标签了解每个应用为什么耗电
4. 获得可操作的省电建议
5. 检查是否有应用阻止 Mac 进入睡眠

## 技术栈

- **语言：** Swift 6.2
- **UI：** SwiftUI + `MenuBarExtra`
- **数据采集：** IOKit（电池）、`ps`（进程）、IOKit PM（睡眠断言）
- **存储：** GRDB.swift（SQLite）
- **最低版本：** macOS 14 Sonoma

## 项目结构

```
PowerLens/
├── App/                  # 应用入口、菜单栏面板、视图模型
├── Collectors/           # 电池、进程、睡眠断言采集器
├── Models/               # 数据模型
├── Scoring/              # 耗电评分计算
├── Recommendations/      # 基于规则的推荐引擎
├── Storage/              # GRDB 事件存储
└── Resources/            # 资源文件、Info.plist、本地化
```

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

[GPLv3](LICENSE)
