import Foundation

@Observable
@MainActor
final class AppSettings {
    static let shared = AppSettings()

    @ObservationIgnored
    private let defaults = UserDefaults.standard

    var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    var collectionInterval: TimeInterval {
        didSet { defaults.set(collectionInterval, forKey: "collectionInterval") }
    }

    var lowBatteryThreshold: Int {
        didSet { defaults.set(lowBatteryThreshold, forKey: "lowBatteryThreshold") }
    }

    var historyRetentionDays: Int {
        didSet { defaults.set(historyRetentionDays, forKey: "historyRetentionDays") }
    }

    var language: String {
        didSet { defaults.set(language, forKey: "language") }
    }

    init() {
        self.launchAtLogin = defaults.object(forKey: "launchAtLogin") as? Bool ?? false
        self.collectionInterval = defaults.object(forKey: "collectionInterval") as? TimeInterval ?? 5.0
        self.lowBatteryThreshold = defaults.object(forKey: "lowBatteryThreshold") as? Int ?? 30
        self.historyRetentionDays = defaults.object(forKey: "historyRetentionDays") as? Int ?? 7
        self.language = defaults.string(forKey: "language") ?? ""
    }
}
