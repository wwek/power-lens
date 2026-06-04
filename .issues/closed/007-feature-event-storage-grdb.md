# [Feature] Event storage with GRDB

**Issue ID**: #007
**Status**: Closed ✅
**Priority**: Medium
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Persist high-power events (Power Score ≥ 60) to a local SQLite database via GRDB. Provide a "Recent Events" section in the panel showing last 24 hours of events. Support clearing history.

End-to-end: Power Score cycle detects App scoring ≥ 60 → creates PowerEvent (timestamp, app name, bundle ID, score, reason tags, suggestions) → writes to SQLite via GRDB → panel "Recent Events" section queries last 24h → displays as timeline → "Clear History" button deletes all records → auto-cleanup removes events older than 7 days on app launch.

## Acceptance criteria

- [x] GRDB added as SPM dependency
- [x] SQLite database created at app support directory on first launch
- [x] PowerEvent table schema: id (UUID), timestamp (Date), appName, bundleIdentifier, powerScore (Int), reasonTags ([String]), suggestions ([String])
- [x] Events written when any App scores ≥ 60
- [x] "Recent Events" section shows last 24 hours, sorted newest first
- [x] Each event shows: time, app name, score, reason tags
- [x] "Clear History" button deletes all events from database
- [x] Events older than 7 days auto-deleted on app launch
- [x] Database operations run on background queue, not blocking UI

## Blocked by

- #004 (Power Score calculation)
