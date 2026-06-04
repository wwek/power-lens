# [Feature] Recommendation engine

**Issue ID**: #006
**Status**: Closed ✅
**Priority**: Medium
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Generate human-readable explanations and actionable suggestions for each high-power App based on its category and reason tags. Built as Swift switch/case rules covering the MVP App categories. Recommendations appear in the menu bar panel below each Top App entry.

End-to-end: App identified with category (browser/docker/dev-tool/etc.) + reason tags → rule engine matches category+tags → generates explanation string + suggestion list → displayed in panel as expandable section per App.

## Acceptance criteria

- [x] Rules cover these categories: Browser, Docker/Container, Developer Tool (VS Code/Cursor/JetBrains), Chat App (WeChat/Slack/Discord), Meeting (Zoom/Teams), Cloud Sync (OneDrive/Dropbox/iCloud), System (Spotlight/Time Machine)
- [x] Each rule produces: 1 explanation sentence + 2–4 actionable suggestions
- [x] Suggestions are safe: no "kill process", prefer "close unused tabs", "pause containers", "quit if not needed"
- [x] Unknown Apps get a generic rule: "This app is using significant resources. Consider quitting if not in use."
- [x] Explanation distinguishes foreground vs background usage: "You are actively using Chrome" vs "Chrome is running in the background"
- [x] All strings use `String(localized:)` keys
- [x] Rules implemented as Swift code (enum + switch), not JSON files

## Blocked by

- #004 (Power Score calculation)
