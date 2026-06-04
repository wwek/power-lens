<p align="center">
  <img src="PowerLens/Resources/Assets.xcassets/AppIcon.appiconset/app-icon-512.png" alt="Power Lens" width="128" height="128">
</p>

<h1 align="center">Power Lens</h1>

<p align="center"><strong>Find what drains your MacBook battery.</strong></p>

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

Power Lens is an open-source macOS menu bar app that explains why your MacBook battery drains fast. It identifies high-power apps, background CPU usage, sleep blockers, and common battery issues — then suggests safe actions.

## Features

- **Open Source** — fully transparent, community-driven
- **Local Only** — all analysis happens on your Mac, zero data uploaded
- **No Telemetry** — no tracking, no analytics, no phoning home
- **App-Level Diagnosis** — aggregates processes into apps and scores them
- **Sleep Blocker Detection** — finds what's preventing your Mac from sleeping
- **Developer Friendly** — detects Docker, dev servers, VS Code, Cursor, and more
- **Safe Recommendations** — explains causes and suggests actions, never auto-kills processes
- **Multilingual** — English, 简体中文, 繁體中文, 日本語, 한국어

## Requirements

- macOS 14 Sonoma or later
- Apple Silicon or Intel Mac

## Installation

### Download

Grab the latest `Power Lens.dmg` from [Releases](../../releases).

### Homebrew

```bash
brew install --cask power-lens
```

### Build from Source

```bash
git clone https://github.com/wwek/power-lens.git
cd power-lens
open PowerLens.xcodeproj
# Press Cmd+R to build and run
```

Or via command line:

```bash
xcodebuild -project PowerLens.xcodeproj -scheme "Power Lens" -configuration Debug build
```

## How It Works

1. Click the menu bar icon to see current battery state and power drain level
2. View top power-hungry apps ranked by Power Score (0–100)
3. See why each app is consuming power with reason tags
4. Get actionable suggestions to extend battery life
5. Check if any apps are preventing your Mac from sleeping

## Tech Stack

- **Language:** Swift 6.2
- **UI:** SwiftUI with `MenuBarExtra`
- **Data Collection:** IOKit (battery), `ps` (processes), IOKit PM (sleep assertions)
- **Storage:** GRDB.swift (SQLite)
- **Minimum Target:** macOS 14 Sonoma

## Project Structure

```
PowerLens/
├── App/                  # App entry, menu bar panel, view models
├── Collectors/           # Battery, process, sleep assertion collectors
├── Models/               # Data models
├── Scoring/              # Power Score calculation
├── Recommendations/      # Rule-based recommendation engine
├── Storage/              # GRDB event store
└── Resources/            # Assets, Info.plist, localizations
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[GPLv3](LICENSE)
