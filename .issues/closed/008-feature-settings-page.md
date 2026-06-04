# [Feature] Settings page

**Issue ID**: #008
**Status**: Closed ✅
**Priority**: Medium
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

A SwiftUI Settings scene with persistent storage via UserDefaults. Covers the MVP settings: launch at login, collection interval, low battery threshold, and history retention days.

End-to-end: User opens Settings from menu bar panel → SwiftUI `Settings` scene opens as native macOS preferences window → user toggles launch-at-login, adjusts slider for collection interval, sets low battery threshold → values saved to UserDefaults immediately → collectors read settings on next cycle → changes take effect without restart.

## Acceptance criteria

- [x] SwiftUI `Settings` scene (native macOS preferences window, not in-app view)
- [x] "Launch at Login" toggle (uses `SMAppService.mainApp` on macOS 13+)
- [x] "Collection Interval" slider: 3s / 5s / 10s / 30s (default 5s)
- [x] "Low Battery Alert Threshold" slider: 10%–50% (default 30%)
- [x] "History Retention" picker: 1 / 3 / 7 / 14 days (default 7)
- [x] All values persisted to `@AppStorage` (UserDefaults)
- [x] Settings changes take effect on next collection cycle without app restart
- [x] All strings use `String(localized:)` keys

## Blocked by

- #001 (Scaffold Xcode project)
