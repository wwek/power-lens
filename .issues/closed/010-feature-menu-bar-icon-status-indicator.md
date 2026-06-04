# [Feature] Menu bar icon with status indicator

**Issue ID**: #010
**Status**: Closed ✅
**Priority**: Medium
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Design and implement the menu bar icon: a lens/magnifying glass icon that serves as the Power Lens brand mark, with a small color dot (green/yellow/red) indicating current power drain level. The dot color updates based on the highest Power Score among running Apps.

End-to-end: App collects power data → determines overall power state (green if all < 30, yellow if any 30–59, orange if any 60–79, red if any ≥ 80) → renders menu bar icon with appropriate dot color → user sees status at a glance without opening panel.

## Acceptance criteria

- [x] Menu bar icon is a lens/magnifying glass shape (SF Symbols or custom asset)
- [x] Status dot overlay: green (Normal), yellow (Moderate), orange (High), red (Abnormal)
- [x] Dot color reflects the highest Power Score across all running Apps
- [x] When charging, show a distinct state (e.g. blue dot or charging icon)
- [x] Icon renders crisply at 22×22 pt in both light and dark menu bar modes
- [x] Light/dark mode adaptive (icon uses correct contrast for current menu bar appearance)
- [x] SF Symbols preferred if suitable symbol exists (e.g. `magnifyingglass`), otherwise custom PDF asset

## Blocked by

- #002 (Battery status display — needs charging state)
- #004 (Power Score calculation — needs scores for state determination)
