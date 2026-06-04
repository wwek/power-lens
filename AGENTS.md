# Power Lens — AGENTS.md

## Project

Power Lens is an open-source macOS menu bar app that helps users find what's draining their MacBook battery. It collects process, battery, and sleep assertion data, scores apps by power drain suspicion, and generates actionable recommendations.

## Tech Stack

- Swift 6.2 + SwiftUI, targeting macOS 14 Sonoma
- Xcode project (no SPM for the app itself; GRDB.swift is the only SPM dependency)
- Concurrency: GCD `DispatchSourceTimer` for collectors, `@Observable` for view models, `@MainActor` for UI state
- Comments in English only

## Architecture

```
App/          → PowerLensApp (entry), PowerLensViewModel (@Observable), MenuBarPanel, SettingsView
Collectors/   → BatteryCollector (IOKit.ps), ProcessCollector (ps shell), SleepAssertionCollector (IOKit.pwr_mgt)
Models/       → BatteryInfo, AppInfo/ProcessSnapshot, SleepAssertionInfo, ScoredApp/PowerEvent, AppSettings
Scoring/      → PowerScorer (3-dimension: CPU 50 + Background 30 + Rule bonus 20)
Recommendations/ → RecommendationEngine (Swift switch/case rules by app category)
Storage/      → EventStore (GRDB SQLite for power events)
Resources/    → Info.plist, Assets.xcassets
```

## Key Decisions

- Process collection uses `ps` shell command, not `proc_pidinfo` (see docs/adr/0001)
- Battery uses IOKit `IOPSCopyPowerSourcesInfo`, not `pmset`
- Sleep assertions use `IOPMCopyAssertionsByProcess` (IOKit.pwr_mgt)
- App aggregation: `NSRunningApplication` primary + hardcoded fallback for CLI processes
- No Swift strict concurrency — `SWIFT_STRICT_CONCURRENCY = minimal`
- `LSUIElement = true` — no Dock icon, menu bar only
- Menu bar uses `MenuBarExtra(.window)` with custom SwiftUI panel
- All UI strings use `String(localized:)`, bilingual EN + ZH

## Build

```bash
xcodebuild -project PowerLens.xcodeproj -scheme "Power Lens" -configuration Debug build
```

## Data Flow

```
GCD timer → Collector → @Sendable callback → Task { @MainActor } → ViewModel property → SwiftUI re-render
```

## Conventions

- `@Observable` + `@MainActor` for view models
- `@Sendable` closures for collector callbacks
- `@ObservationIgnored` for non-reactive stored properties
- `String(localized:)` for all user-facing strings
- No Combine, no RxSwift, no async/await for collectors
