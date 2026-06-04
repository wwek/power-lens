import Foundation
import AppKit

final class ProcessCollector {
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.powerlens.process", qos: .utility)
    private var callback: (@Sendable ([AppInfo]) -> Void)?

    private static let knownProcessRules: [String: String] = [
        "node": "Node.js",
        "python3": "Python",
        "python": "Python",
        "mds": "Spotlight",
        "mds_stores": "Spotlight",
        "backupd": "Time Machine",
        "caffeinate": "Caffeinate",
    ]

    func start(interval: TimeInterval = 5.0, onUpdate: @escaping @Sendable ([AppInfo]) -> Void) {
        self.callback = onUpdate
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval, leeway: .seconds(1))
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            let apps = self.collect()
            onUpdate(apps)
        }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func collect() -> [AppInfo] {
        let snapshots = runPS()
        let runningApps = NSWorkspace.shared.runningApplications
        var appMap: [pid_t: NSRunningApplication] = [:]
        for app in runningApps {
            appMap[app.processIdentifier] = app
        }

        let frontmostPID = NSWorkspace.shared.frontmostApplication?.processIdentifier ?? -1
        let selfPID = ProcessInfo.processInfo.processIdentifier

        // Group processes by app identity
        var grouped: [String: (name: String, bundleID: String?, cpu: Double, mem: Int, count: Int, isBackground: Bool)] = [:]

        for snap in snapshots {
            if snap.pid == selfPID { continue }

            let (key, name, bundleID) = resolveAppIdentity(pid: snap.pid, command: snap.command, appMap: appMap)

            if var existing = grouped[key] {
                existing.cpu += snap.cpuPercent
                existing.mem += snap.memoryKB / 1024
                existing.count += 1
                grouped[key] = existing
            } else {
                let isBackground = snap.pid != frontmostPID
                grouped[key] = (name: name, bundleID: bundleID, cpu: snap.cpuPercent, mem: snap.memoryKB / 1024, count: 1, isBackground: isBackground)
            }
        }

        let apps = grouped.map { key, val in
            AppInfo(
                id: key,
                appName: val.name,
                bundleIdentifier: val.bundleID,
                cpuPercent: min(val.cpu, 100.0),
                memoryMB: val.mem,
                processCount: val.count,
                isBackground: val.isBackground
            )
        }

        return apps.sorted { $0.cpuPercent > $1.cpuPercent }
    }

    private func resolveAppIdentity(pid: pid_t, command: String, appMap: [pid_t: NSRunningApplication]) -> (key: String, name: String, bundleID: String?) {
        if let app = appMap[pid], let bundleID = app.bundleIdentifier {
            let name = app.localizedName ?? command
            return (bundleID, name, bundleID)
        }

        // Check if this process is a child of a known app
        for (_, app) in appMap {
            // Match by executable path prefix (e.g. Chrome Helper → Chrome)
            if let url = app.bundleURL {
                let execName = url.deletingPathExtension().lastPathComponent
                if command.contains(execName) || command.hasPrefix(execName) {
                    let name = app.localizedName ?? execName
                    let bundleID = app.bundleIdentifier ?? execName
                    return (bundleID, name, bundleID)
                }
            }
        }

        // Fallback to known process rules
        if let mapped = Self.knownProcessRules[command] {
            return (command, mapped, nil)
        }

        return (command, command, nil)
    }

    private func runPS() -> [ProcessSnapshot] {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-Aceo", "pid,pcpu,rss,comm", "-r"]
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        var results: [ProcessSnapshot] = []
        let lines = output.components(separatedBy: "\n")

        for line in lines.dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 4,
                  let pid = Int32(parts[0]),
                  let cpu = Double(parts[1]),
                  let rss = Int(parts[2]) else { continue }

            let command = parts[3...].joined(separator: " ")
            results.append(ProcessSnapshot(pid: pid, command: command, cpuPercent: cpu, memoryKB: rss))
        }

        return results
    }
}
