import Foundation

struct Recommendation: Identifiable, Sendable {
    let id = UUID()
    let appName: String
    let explanation: String
    let suggestions: [String]
}

enum AppCategory: String, Sendable {
    case browser
    case docker
    case developerTool
    case chatApp
    case meeting
    case cloudSync
    case system
    case unknown
}

struct RecommendationEngine {
    private static let bundleCategoryMap: [String: AppCategory] = [
        "com.google.Chrome": .browser,
        "com.microsoft.edgemac": .browser,
        "com.apple.Safari": .browser,
        "org.mozilla.firefox": .browser,
        "com.docker.docker": .docker,
        "com.electron.docker-desktop": .docker,
        "io.orbstack": .docker,
        "com.microsoft.VSCode": .developerTool,
        "com.todesktop.230313mchl4q4u92": .developerTool, // Cursor
        "com.apple.dt.Xcode": .developerTool,
        "com.jetbrains.intellij": .developerTool,
        "com.apple.finder": .chatApp, // placeholder
        "com.tencent.xinWeChat": .chatApp,
        "com.tencent.WeWork": .chatApp,
        "com.bytedance.lark": .chatApp,
        "com.colliderli.iina": .chatApp, // not really, placeholder
        "com.spotify.client": .chatApp,
        "us.zoom.xos": .meeting,
        "com.microsoft.teams": .meeting,
        "com.tencent.meeting": .meeting,
        "com.microsoft.skydrive-mac": .cloudSync,
        "com.getdropbox.dropbox": .cloudSync,
        "com.apple.bird": .cloudSync, // iCloud Drive
    ]

    private static let processCategoryMap: [String: AppCategory] = [
        "node": .developerTool,
        "python3": .developerTool,
        "python": .developerTool,
        "mds": .system,
        "mds_stores": .system,
        "backupd": .system,
    ]

    func generate(for app: ScoredApp) -> Recommendation? {
        guard app.powerScore >= 30 else { return nil }

        let category = categorize(app: app)
        let isBackground = app.isBackground
        let hasHighCPU = app.cpuPercent > 10
        let manyProcesses = app.processCount > 3

        let (explanation, suggestions) = generateContent(
            category: category,
            appName: app.appName,
            isBackground: isBackground,
            hasHighCPU: hasHighCPU,
            manyProcesses: manyProcesses
        )

        return Recommendation(
            appName: app.appName,
            explanation: explanation,
            suggestions: suggestions
        )
    }

    private func categorize(app: ScoredApp) -> AppCategory {
        if let bundleID = app.bundleIdentifier,
           let cat = Self.bundleCategoryMap[bundleID] {
            return cat
        }
        if let cat = Self.processCategoryMap[app.appName] {
            return cat
        }
        // Heuristic: check app name
        let name = app.appName.lowercased()
        if name.contains("chrome") || name.contains("firefox") || name.contains("safari") || name.contains("edge") {
            return .browser
        }
        if name.contains("docker") || name.contains("orbstack") {
            return .docker
        }
        if name.contains("code") || name.contains("cursor") || name.contains("xcode") || name.contains("intellij") {
            return .developerTool
        }
        return .unknown
    }

    private func generateContent(
        category: AppCategory,
        appName: String,
        isBackground: Bool,
        hasHighCPU: Bool,
        manyProcesses: Bool
    ) -> (explanation: String, suggestions: [String]) {
        switch category {
        case .browser:
            let bg = isBackground
            return (
                bg
                    ? String(localized: "\(appName) is running in the background with high CPU. This may be caused by video, live streams, WebGL pages, or browser extensions.")
                    : String(localized: "\(appName) is using significant resources. Too many open tabs or active extensions can increase power draw."),
                [
                    String(localized: "Close unused tabs"),
                    String(localized: "Check browser extensions"),
                    String(localized: "Close video or live stream pages"),
                    String(localized: "Restart the browser"),
                ]
            )

        case .docker:
            return (
                String(localized: "\(appName) is running containers or services that consume CPU and disk I/O."),
                [
                    String(localized: "Pause non-essential containers"),
                    String(localized: "Stop local databases or background services"),
                    String(localized: "Consider quitting \(appName) while on battery"),
                ]
            )

        case .developerTool:
            return (
                isBackground
                    ? String(localized: "\(appName) is consuming power in the background. Plugins, indexing, or dev servers may be active.")
                    : String(localized: "\(appName) is actively using resources. Build processes, indexing, or extensions can increase power draw."),
                [
                    String(localized: "Stop unused dev servers"),
                    String(localized: "Close unused project windows"),
                    String(localized: "Check if plugins are misbehaving"),
                    String(localized: "Restart the editor"),
                ]
            )

        case .chatApp:
            return (
                String(localized: "\(appName) is active in the background with network or CPU usage. File transfers, video calls, or message syncing may be the cause."),
                [
                    String(localized: "Quit if not needed"),
                    String(localized: "Check for active file transfers or calls"),
                    String(localized: "Close unnecessary chat windows"),
                ]
            )

        case .meeting:
            return (
                String(localized: "\(appName) is an active meeting app with high audio/video processing."),
                [
                    String(localized: "Use audio-only mode if video is not needed"),
                    String(localized: "Close the app after the meeting ends"),
                ]
            )

        case .cloudSync:
            return (
                String(localized: "\(appName) is actively syncing files, consuming network and disk resources."),
                [
                    String(localized: "Pause syncing while on battery"),
                    String(localized: "Check for large file uploads or downloads"),
                ]
            )

        case .system:
            return (
                String(localized: "\(appName) is performing system tasks. This is usually temporary."),
                [
                    String(localized: "Wait for the task to complete"),
                    String(localized: "This is normal system behavior in most cases"),
                ]
            )

        case .unknown:
            return (
                isBackground
                    ? String(localized: "\(appName) is using significant resources in the background.")
                    : String(localized: "\(appName) is using significant resources."),
                [
                    String(localized: "Consider quitting if not in use"),
                    String(localized: "Check Activity Monitor for details"),
                ]
            )
        }
    }
}
