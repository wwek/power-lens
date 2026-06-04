import Foundation

struct SleepAssertionInfo: Identifiable, Sendable {
    let id: String // pid + assertionType
    let pid: Int32
    let processName: String
    let appName: String
    let assertionType: String
    let localizedDescription: String
    let suggestion: String
}
