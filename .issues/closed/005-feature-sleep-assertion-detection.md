# [Feature] Sleep assertion detection

**Issue ID**: #005
**Status**: Closed ✅
**Priority**: High
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Detect processes holding sleep assertions via IOKit API, map them to user-facing App names, and display in a dedicated section of the menu bar panel. Show assertion type, responsible App, and a brief suggestion.

End-to-end: poll `IOPMCopyAssertionsByProcess` every 30s → extract PIDs and assertion types → map to Apps via `NSRunningApplication` → display in panel section "Preventing Sleep" → each entry shows App name, assertion reason, and one-line suggestion.

## Acceptance criteria

- [x] Detects processes holding PreventUserIdleSystemSleep, PreventUserIdleDisplaySleep, and BackgroundTask assertions
- [x] PIDs mapped to App names via `NSRunningApplication`
- [x] Special recognition for known tools: Amphetamine ("Keeping Mac awake"), Caffeinate ("Caffeinate active")
- [x] System processes shown with friendly names: `backupd`→"Time Machine", `mds`→"Spotlight Indexing"
- [x] Panel section "Preventing Sleep" appears only when assertions exist, hidden otherwise
- [x] Suggestion shown per entry: e.g. "Close if you want Mac to sleep normally"
- [x] Uses IOKit API, not `pmset -g assertions` text parsing

## Blocked by

- #001 (Scaffold Xcode project)
