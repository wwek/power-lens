# [Feature] Scaffold Xcode project with Menu Bar App

**Issue ID**: #001
**Status**: Closed ✅
**Priority**: High
**Created**: 2026-06-04
**Updated**: 2026-06-04
**Closed**: 2026-06-04
**Assignee**: Unassigned
**Labels**: feature, mvp

---

## What to build

Create the Xcode project from scratch. The app launches as a macOS menu bar app (no Dock icon, no main window by default). Clicking the menu bar icon opens a `MenuBarExtra(.window)` panel with placeholder content. The project structure follows the agreed directory layout.

End-to-end: App launches → menu bar icon visible → click icon → floating panel appears with placeholder text → panel can be closed.

## Acceptance criteria

- [x] Xcode project targets macOS 14 (deployment target), built with Swift 6.2 + SwiftUI
- [x] App runs as menu bar only (LSUIElement = true, no Dock icon)
- [x] `MenuBarExtra(.window)` shows a ~320px wide panel on click
- [x] Panel displays placeholder content: app name "Power Lens" and "Hello" text
- [x] Project directory structure matches:
  ```
  PowerLens/
  ├── App/
  ├── Collectors/
  ├── Models/
  ├── Scoring/
  ├── Recommendations/
  ├── Storage/
  └── Resources/
  ```
- [x] App binary name is "Power Lens" (with space), bundle identifier `com.powerlens.app`
- [x] Builds and runs without warnings on Xcode 26

## Blocked by

None — can start immediately.
