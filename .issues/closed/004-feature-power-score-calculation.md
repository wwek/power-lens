# [Feature] Power Score calculation

**Issue ID**: #004
**Status**: Closed ✅
**Priority**: High
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Calculate a 0–100 Power Score for each App using the MVP 3-dimension formula. Generate reason tags (High CPU, Background Active, etc.) for Apps scoring ≥ 30. Display scores and tags alongside the App list in the menu bar panel.

End-to-end: process data from #003 feeds into scorer → CPU weight (50) + background weight (30) + rule bonus (20) → clamp to 0–100 → map score to drain level (Normal/Moderate/High/Abnormal) → generate reason tags → view model updates → panel renders scores with colored badges and reason tags.

## Acceptance criteria

- [x] Each App has a 0–100 Power Score
- [x] Score formula: CPU%(capped at 100, ×0.5) + Background(0 or 30) + Rule bonus(0 or 20)
- [x] Background detection: App is "background" if not `NSWorkspace.shared.frontmostApplication` AND cpu > 0
- [x] Rule bonus: +20 for known high-drain patterns (Docker on battery, browser with many children, meeting apps active)
- [x] Drain level mapping: 0–29 Normal, 30–59 Moderate, 60–79 High, 80–100 Abnormal
- [x] Reason tags generated for Apps scoring ≥ 30: "High CPU" (cpu > 10%), "Background Active", "Many Child Processes" (> 3 children), "High Memory" (memory > 500MB)
- [x] Scores update every collection cycle (5s)
- [x] Panel shows score as colored number (green/yellow/orange/red) with reason tags as pill badges

## Blocked by

- #003 (Process collection and App aggregation)
