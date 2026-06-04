import Foundation

struct PowerScorer {
    /// Known high-drain bundle identifiers that get a rule bonus on battery
    private static let highDrainOnBattery: Set<String> = [
        "com.docker.docker",
        "com.electron.docker-desktop",
        "com.microsoft.VSCode",
        "com.todesktop.230313mchl4q4u92", // Cursor
    ]

    /// Meeting app bundle IDs
    private static let meetingApps: Set<String> = [
        "us.zoom.xos",
        "com.microsoft.teams",
        "com.tencent.meeting",
    ]

    func score(apps: [AppInfo], isOnBattery: Bool) -> [ScoredApp] {
        apps.map { app in
            let cpuComponent = min(app.cpuPercent, 100.0) * 0.5
            let backgroundComponent: Double = app.isBackground && app.cpuPercent > 0 ? 30.0 : 0.0
            let ruleBonus = calculateRuleBonus(app: app, isOnBattery: isOnBattery)

            let rawScore = cpuComponent + backgroundComponent + ruleBonus
            let score = Int(min(max(rawScore, 0), 100))

            var tags: [ReasonTag] = []
            if app.cpuPercent > 10 { tags.append(.highCPU) }
            if app.isBackground && app.cpuPercent > 0 { tags.append(.backgroundActive) }
            if app.processCount > 3 { tags.append(.manyChildProcesses) }
            if app.memoryMB > 500 { tags.append(.highMemory) }

            return ScoredApp(
                id: app.id,
                appName: app.appName,
                bundleIdentifier: app.bundleIdentifier,
                cpuPercent: app.cpuPercent,
                memoryMB: app.memoryMB,
                processCount: app.processCount,
                isBackground: app.isBackground,
                powerScore: score,
                drainLevel: .from(score: score),
                reasonTags: tags
            )
        }
        .sorted { $0.powerScore > $1.powerScore }
    }

    private func calculateRuleBonus(app: AppInfo, isOnBattery: Bool) -> Double {
        guard let bundleID = app.bundleIdentifier else { return 0 }

        // Docker or dev tools running on battery get bonus
        if isOnBattery && Self.highDrainOnBattery.contains(bundleID) {
            return 20.0
        }

        // Meeting apps active get bonus
        if Self.meetingApps.contains(bundleID) && app.cpuPercent > 5 {
            return 20.0
        }

        // Browser with many child processes
        if app.processCount > 5 && app.cpuPercent > 10 {
            return 20.0
        }

        return 0.0
    }
}
