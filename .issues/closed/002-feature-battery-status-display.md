# [Feature] Battery status display

**Issue ID**: #002
**Status**: Closed ✅
**Priority**: High
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Collect battery data via IOKit and display it in the menu bar panel. The app shows: battery percentage, charging/discharging state, power source (AC/battery), estimated time remaining, and low power mode status. On devices without a battery (Mac mini, Mac Pro), show "Battery not available".

End-to-end: IOKit queries battery → data flows to `@Observable` view model → menu bar panel renders battery status card → status updates in real-time when charger is connected/disconnected.

## Acceptance criteria

- [x] Battery percentage displayed, accurate to ±1%
- [x] Charging vs on-battery state correctly detected
- [x] Low power mode status shown when enabled
- [x] Estimated time remaining displayed (hours + minutes)
- [x] "Battery not available" shown on devices without battery
- [x] State updates within 2 seconds of charger connect/disconnect (using IOPSNotificationCreateRunLoopSource or equivalent polling)
- [x] Battery collector uses IOKit `IOPSCopyPowerSourcesInfo`, not `pmset` shell command
- [x] All UI strings use `String(localized:)` keys

## Blocked by

- #001 (Scaffold Xcode project)
