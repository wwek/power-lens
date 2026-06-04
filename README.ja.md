<p align="center">
  <img src="PowerLens/Resources/Assets.xcassets/AppIcon.appiconset/app-icon-512.png" alt="Power Lens" width="128" height="128">
</p>

<h1 align="center">Power Lens</h1>

<p align="center"><strong>MacBook のバッテリーを消費している原因を見つけよう。</strong></p>

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

Power Lens は、MacBook のバッテリーがなぜ早く減るのかを診断するオープンソースの macOS メニューバーアプリです。高消費電力アプリ、バックグラウンド CPU 使用率、スリープ阻止アプリを検出し、安全な対策を提案します。

## 特徴

- **オープンソース** — 完全に透明で、コミュニティ主導
- **ローカル動作** — すべての分析は Mac 上で完結、データのアップロードなし
- **テレメトリなし** — 追跡・分析・データ送信なし
- **アプリレベル診断** — プロセスをアプリにまとめてスコアリング
- **スリープ阻止検出** — Mac のスリープを妨げているアプリを特定
- **開発者フレンドリー** — Docker、開発サーバー、VS Code、Cursor などを検出
- **安全な提案** — 原因を説明し対策を提案、プロセスを自動終了しない
- **多言語対応** — English、简体中文、繁體中文、日本語、한국어

## 動作環境

- macOS 14 Sonoma 以降
- Apple Silicon または Intel Mac

## インストール

### ダウンロード

[Releases](../../releases) から最新の `Power Lens.dmg` をダウンロードしてください。

### Homebrew

```bash
brew install --cask power-lens
```

### ソースからビルド

```bash
git clone https://github.com/wwek/power-lens.git
cd power-lens
open PowerLens.xcodeproj
# Cmd+R でビルド＆実行
```

コマンドラインの場合：

```bash
xcodebuild -project PowerLens.xcodeproj -scheme "Power Lens" -configuration Debug build
```

## 使い方

1. メニューバーアイコンをクリックしてバッテリー状態と消費レベルを確認
2. 消費スコア（0–100）でランキングされた高消費アプリを確認
3. 理由タグで各アプリがなぜ電力を消費しているかを確認
4. バッテリー持ちを改善する実用的な提案を取得
5. Mac のスリープを妨げているアプリがないか確認

## 技術スタック

- **言語：** Swift 6.2
- **UI：** SwiftUI + `MenuBarExtra`
- **データ収集：** IOKit（バッテリー）、`ps`（プロセス）、IOKit PM（スリープアサーション）
- **ストレージ：** GRDB.swift（SQLite）
- **最小ターゲット：** macOS 14 Sonoma

## プロジェクト構成

```
PowerLens/
├── App/                  # アプリエントリ、メニューバーパネル、ビューモデル
├── Collectors/           # バッテリー、プロセス、スリープアサーションコレクタ
├── Models/               # データモデル
├── Scoring/              # 消費スコア計算
├── Recommendations/      # ルールベース推奨エンジン
├── Storage/              # GRDB イベントストア
└── Resources/            # アセット、Info.plist、ローカライズ
```

## コントリビュート

コントリビューションを歓迎します！お気軽に Pull Request を提出してください。

## ライセンス

[GPLv3](LICENSE)
