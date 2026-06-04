<p align="center">
  <img src="PowerLens/Resources/Assets.xcassets/AppIcon.appiconset/app-icon-512.png" alt="Power Lens" width="128" height="128">
</p>

<h1 align="center">Power Lens</h1>

<p align="center"><strong>找出是什麼在消耗你的 MacBook 電池。</strong></p>

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

Power Lens 是一款開源 macOS 選單列應用程式，幫你診斷 MacBook 電池為什麼耗電快。它識別高耗電應用程式、背景 CPU 佔用、睡眠阻止項，並給出安全建議。

## 功能特性

- **開源** — 完全透明，社群驅動
- **本機運行** — 所有分析都在你的 Mac 上完成，零資料上傳
- **無遙測** — 無追蹤、無分析、無資料回報
- **應用程式級診斷** — 將程序聚合成應用程式並評分
- **睡眠阻止偵測** — 找出阻止 Mac 睡眠的應用程式
- **開發者友善** — 識別 Docker、開發伺服器、VS Code、Cursor 等
- **安全建議** — 解釋原因並建議操作，絕不自動終止程序
- **多語言** — English、简体中文、繁體中文、日本語、한국어

## 系統需求

- macOS 14 Sonoma 或更高版本
- Apple Silicon 或 Intel Mac

## 安裝

### 下載安裝

從 [Releases](../../releases) 下載最新的 `Power Lens.dmg`。

### Homebrew 安裝

```bash
brew install --cask power-lens
```

### 從原始碼建構

```bash
git clone https://github.com/wwek/power-lens.git
cd power-lens
open PowerLens.xcodeproj
# 按 Cmd+R 建構並執行
```

或透過命令列：

```bash
xcodebuild -project PowerLens.xcodeproj -scheme "Power Lens" -configuration Debug build
```

## 使用方法

1. 點擊選單列圖示查看目前電池狀態和耗電等級
2. 查看按耗電評分（0–100）排名的高耗電應用程式
3. 透過原因標籤了解每個應用程式為什麼耗電
4. 獲得可操作的省電建議
5. 檢查是否有應用程式阻止 Mac 進入睡眠

## 技術棧

- **語言：** Swift 6.2
- **UI：** SwiftUI + `MenuBarExtra`
- **資料收集：** IOKit（電池）、`ps`（程序）、IOKit PM（睡眠斷言）
- **儲存：** GRDB.js (SQLite)
- **最低版本：** macOS 14 Sonoma

## 專案結構

```
PowerLens/
├── App/                  # 應用程式入口、選單列面板、視圖模型
├── Collectors/           # 電池、程序、睡眠斷言收集器
├── Models/               # 資料模型
├── Scoring/              # 耗電評分計算
├── Recommendations/      # 基於規則的推薦引擎
├── Storage/              # GRDB 事件儲存
└── Resources/            # 資源檔案、Info.plist、在地化
```

## 貢獻

歡迎貢獻！請隨時提交 Pull Request。

## 授權條款

[GPLv3](LICENSE)
