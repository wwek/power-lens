import Foundation
import IOKit
import IOKit.pwr_mgt
import AppKit

final class SleepAssertionCollector {
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.powerlens.sleep", qos: .utility)

    private static let knownProcessNames: [String: (name: String, description: String, suggestion: String)] = [
        "Amphetamine": ("Amphetamine", String(localized: "Keeping Mac awake"), String(localized: "Close if you want Mac to sleep normally")),
        "caffeinate": ("Caffeinate", String(localized: "Caffeinate active"), String(localized: "Terminal command keeping Mac awake")),
        "backupd": ("Time Machine", String(localized: "Time Machine backup in progress"), String(localized: "Wait for backup to finish, or pause while on battery")),
        "mds": ("Spotlight", String(localized: "Spotlight indexing"), String(localized: "Usually temporary; consider excluding large directories if persistent")),
        "mds_stores": ("Spotlight", String(localized: "Spotlight indexing"), String(localized: "Usually temporary; consider excluding large directories if persistent")),
        "com.apple.backboardd": ("System", String(localized: "System keeping display active"), String(localized: "Normal system behavior")),
    ]

    private static let assertionTypeLabels: [String: String] = [
        "PreventUserIdleSystemSleep": String(localized: "Preventing system sleep"),
        "PreventUserIdleDisplaySleep": String(localized: "Preventing display sleep"),
        "NoDisplaySleepAssertion": String(localized: "Preventing display sleep"),
        "BackgroundTask": String(localized: "Background task active"),
        "PreventSystemSleep": String(localized: "Preventing system sleep"),
    ]

    func start(interval: TimeInterval = 30.0, onUpdate: @escaping @Sendable ([SleepAssertionInfo]) -> Void) {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval, leeway: .seconds(5))
        timer.setEventHandler { [weak self] in
            let assertions = self?.collect() ?? []
            onUpdate(assertions)
        }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func collect() -> [SleepAssertionInfo] {
        var assertionsDictRef: Unmanaged<CFDictionary>?
        let result = IOPMCopyAssertionsByProcess(&assertionsDictRef)
        guard result == kIOReturnSuccess, let cfDict = assertionsDictRef?.takeRetainedValue() else {
            return []
        }
        guard let assertionsDict = cfDict as? [Int32: [[String: Any]]] else {
            return []
        }

        let runningApps = NSWorkspace.shared.runningApplications
        var appMap: [pid_t: NSRunningApplication] = [:]
        for app in runningApps {
            let pid = app.processIdentifier
            appMap[pid] = app
        }

        var results: [SleepAssertionInfo] = []

        for (pid, assertions) in assertionsDict {
            for assertion in assertions {
                guard let assertType = assertion["AssertionType"] as? String else { continue }

                let processName = assertion["Creator"] as? String ?? "Unknown"
                let (appName, _, suggestion) = resolveInfo(pid: pid, processName: processName, appMap: appMap)
                let typeLabel = Self.assertionTypeLabels[assertType] ?? assertType

                results.append(SleepAssertionInfo(
                    id: "\(pid)-\(assertType)",
                    pid: pid,
                    processName: processName,
                    appName: appName,
                    assertionType: assertType,
                    localizedDescription: typeLabel,
                    suggestion: suggestion
                ))
            }
        }

        return results
    }

    private func resolveInfo(pid: pid_t, processName: String, appMap: [pid_t: NSRunningApplication]) -> (name: String, description: String, suggestion: String) {
        if let known = Self.knownProcessNames[processName] {
            return known
        }

        if let app = appMap[pid] {
            let name = app.localizedName ?? processName
            return (name, String(localized: "Preventing Mac from sleeping"), String(localized: "Close if you want Mac to sleep normally"))
        }

        return (processName, String(localized: "Preventing Mac from sleeping"), String(localized: "Check if this app needs to keep Mac awake"))
    }
}
