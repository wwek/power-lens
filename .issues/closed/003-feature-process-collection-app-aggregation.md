# [Feature] Process collection and App aggregation

**Issue ID**: #003
**Status**: Closed ✅
**Priority**: High
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Collect per-process CPU and memory usage via `ps` shell command, aggregate child processes into parent Apps using `NSRunningApplication`, and display a Top 5 CPU-consuming Apps list in the menu bar panel.

End-to-end: GCD timer fires every 5s → spawns `ps -Aceo pid,pcpu,rss,comm -r` → parses output → maps PIDs to Apps via `NSRunningApplication` → aggregates child processes → view model updates → panel renders ranked App list with CPU% and memory.

## Acceptance criteria

- [x] Top 5 Apps by CPU usage displayed with app name, CPU%, and memory usage
- [x] Chrome Helper / Chrome Helper GPU / Chrome Helper Renderer all aggregate under "Google Chrome"
- [x] Docker's multiple processes aggregate under "Docker Desktop"
- [x] Apps with `NSRunningApplication` entry show their localized name (e.g. "微信" not "WeChatApp")
- [x] Unknown CLI processes show their process name (e.g. "node", "python3")
- [x] Hardcoded fallback rules cover: `node`→Node.js, `mds`/`mds_stores`→Spotlight, `backupd`→Time Machine
- [x] Collection uses `Process` + `Pipe`, not `proc_pidinfo`
- [x] Collection runs on a background GCD serial queue, UI updates on `@MainActor`
- [x] Self (Power Lens) is excluded from the list

## Blocked by

- #001 (Scaffold Xcode project)
