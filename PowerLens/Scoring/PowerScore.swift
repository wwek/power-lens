import Foundation

enum DrainLevel: String, Sendable {
    case normal
    case moderate
    case high
    case abnormal

    var localizedLabel: String {
        switch self {
        case .normal: String(localized: "Normal")
        case .moderate: String(localized: "Moderate")
        case .high: String(localized: "High")
        case .abnormal: String(localized: "Abnormal")
        }
    }

    static func from(score: Int) -> DrainLevel {
        switch score {
        case 0..<30: .normal
        case 30..<60: .moderate
        case 60..<80: .high
        default: .abnormal
        }
    }
}

enum ReasonTag: String, CaseIterable, Sendable {
    case highCPU = "High CPU"
    case backgroundActive = "Background Active"
    case manyChildProcesses = "Many Processes"
    case highMemory = "High Memory"

    var localizedLabel: String {
        switch self {
        case .highCPU: String(localized: "High CPU")
        case .backgroundActive: String(localized: "Background Active")
        case .manyChildProcesses: String(localized: "Many Processes")
        case .highMemory: String(localized: "High Memory")
        }
    }
}

struct ScoredApp: Identifiable, Sendable {
    let id: String
    let appName: String
    let bundleIdentifier: String?
    let cpuPercent: Double
    let memoryMB: Int
    let processCount: Int
    let isBackground: Bool
    let powerScore: Int
    let drainLevel: DrainLevel
    let reasonTags: [ReasonTag]
}
