import Foundation

struct ProcessSnapshot: Sendable {
    let pid: Int32
    let command: String
    let cpuPercent: Double
    let memoryKB: Int
}

struct AppInfo: Identifiable, Sendable {
    let id: String // bundleIdentifier or command as fallback
    let appName: String
    let bundleIdentifier: String?
    let cpuPercent: Double
    let memoryMB: Int
    let processCount: Int
    let isBackground: Bool
}
