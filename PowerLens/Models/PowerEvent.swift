import Foundation

struct PowerEvent: Identifiable, Sendable, Codable {
    let id: String
    let timestamp: Date
    let appName: String
    let bundleIdentifier: String?
    let powerScore: Int
    let reasonTags: [String]
    let suggestions: [String]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        appName: String,
        bundleIdentifier: String?,
        powerScore: Int,
        reasonTags: [String],
        suggestions: [String]
    ) {
        self.id = id.uuidString
        self.timestamp = timestamp
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.powerScore = powerScore
        self.reasonTags = reasonTags
        self.suggestions = suggestions
    }
}
