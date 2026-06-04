# [Feature] Localization (EN + ZH)

**Issue ID**: #009
**Status**: Closed ✅
**Priority**: Medium
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Audit all user-facing strings across the app and ensure every one uses `String(localized:)` with a String Catalog (`Localizable.xcstrings`). Provide English + Simplified Chinese translations for all strings. This covers: menu bar panel labels, battery status text, Power Score drain levels, reason tags, recommendation texts, sleep assertion descriptions, settings labels, and event timeline entries.

End-to-end: User changes system language to Chinese → all Power Lens UI text appears in Simplified Chinese → switch to English → all text appears in English. No hardcoded strings remain.

## Acceptance criteria

- [x] All UI strings use `String(localized:)` or `Text("key")` with localization — zero hardcoded user-facing strings
- [x] `Localizable.xcstrings` (String Catalog) created with EN + ZH columns
- [x] English strings are complete and natural (not machine-translated)
- [x] Simplified Chinese strings are complete and natural
- [x] Reason tags localized: "High CPU" / "CPU 占用高", "Background Active" / "后台活跃", etc.
- [x] Drain levels localized: "Normal" / "正常", "Moderate" / "中等", "High" / "高", "Abnormal" / "异常"
- [x] Recommendation texts fully translated
- [x] Settings labels fully translated
- [x] Code audited: `grep -r '\"[A-Z]` finds no hardcoded English strings in SwiftUI views

## Blocked by

- #002 (Battery status display)
- #003 (Process collection and App aggregation)
- #006 (Recommendation engine)
