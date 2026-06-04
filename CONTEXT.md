# Power Lens — Context

## Glossary

### Power Score
A 0–100 heuristic score estimating how likely an app is contributing to battery drain. Not a watt measurement — a relative "suspicion ranking" so users can prioritize what to act on.

### App vs Process
A **Process** is an OS-level running instance (pid). An **App** is a user-facing application that may own multiple processes (e.g. Chrome + Chrome Helper GPU). Power Lens aggregates processes into Apps for display.

### Power Event
A timestamped record of a significant power-related occurrence: high-power app detected, sleep prevented, battery draining fast, etc. Stored locally, retained 7 days by default.

### Sleep Assertion
A macOS IOPMAssertion that prevents the system or display from sleeping. Power Lens detects which processes hold assertions and maps them to Apps.

### Power State
The overall battery drain level: Normal, Moderate, High, Abnormal. Determined by aggregate Power Scores and battery discharge rate.

### Drain Level (per App)
Mapped from Power Score: 0–29 Normal, 30–59 Moderate, 60–79 High, 80–100 Abnormal.

### Reason Tag
A short label attached to a high-power App explaining *why* it's consuming power: High CPU, Background Active, Preventing Sleep, etc.

### Recommendation
A safe, actionable suggestion tied to a specific App and its reason tags. Never auto-executes — always requires user action.

### Rule Engine
Matches an App's category + reason tags to predefined rules that generate explanation text and recommendations.

### Collector
A module that periodically samples a specific data source: battery status, process info, sleep assertions, disk I/O, network I/O.

## V0.1 MVP Decisions

| Decision | Choice | Why |
|---|---|---|
| Deployment Target | macOS 14 Sonoma | `@Observable` macro, stable `MenuBarExtra`, ~90%+ coverage |
| Tech Stack | Swift 6.2 + SwiftUI + Xcode 26 | Latest toolchain on Apple Silicon |
| Concurrency | GCD DispatchSourceTimer | Industry standard for system monitors (Stats, eul); natural fit for polling pattern |
| Process Collection | Shell (`ps`/`top`) via `Process`+`Pipe` | Verified by Stats (20k stars); simpler than `proc_pidinfo` |
| CPU/Memory Collection | Mach API (`host_statistics`) | Zero-overhead, all major tools use this |
| Battery Collection | IOKit (`IOPSCopyPowerSourcesInfo` + CFRunLoop push) | Push notifications for state changes, no polling needed |
| Sleep Assertion Detection | IOKit API (`IOPMCopyAssertionsByProcess`) | Structured data, no text parsing, no process spawn |
| App Aggregation | `NSRunningApplication` primary + hardcoded fallback | Covers 90%+ of user apps; only CLI/system processes need rules |
| Power Score (MVP) | 3-dimension: CPU(50) + Background(30) + Rule bonus(20) | Core signals cover 80% of drain scenarios; V0.2 adds I/O and sustained CPU |
| Recommendation Engine | Swift built-in rules (switch/case) | ~10 rules for MVP; JSON engine deferred to V0.2 |
| Data Storage | UserDefaults (settings) + GRDB (events) | SQL for event queries/aggregation/cleanup; settings are simple key-value |
| Menu Bar | `MenuBarExtra(.window)` with custom SwiftUI panel | Richer layout than `.menu` mode; native API replaces manual NSPopover |
| Notifications | Not in MVP | Menu bar icon state changes suffice; V0.2 adds system notifications |
| Localization | English + Simplified Chinese from day one | `String(localized:)` + String Catalog; covers top two user bases |
| macOS 13 Compatibility | No fallback, macOS 14 required | Avoids maintaining two MenuBar + two state management approaches |
| Distribution | GitHub Release (dmg) + Homebrew Cask | No App Store sandbox restrictions on IOKit/process access |
| Menu Bar Icon | Lens icon + status color dot (green/yellow/red) | Brand identity, no confusion with system battery icon |
