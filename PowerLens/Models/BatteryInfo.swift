import Foundation

struct BatteryInfo: Sendable {
    let percentage: Int
    let isCharging: Bool
    let isOnBattery: Bool
    let timeRemaining: Int? // minutes, nil if unknown or on AC
    let isLowPowerMode: Bool
    let isAvailable: Bool

    static let unavailable = BatteryInfo(
        percentage: 0,
        isCharging: false,
        isOnBattery: false,
        timeRemaining: nil,
        isLowPowerMode: false,
        isAvailable: false
    )

    var timeRemainingFormatted: String {
        guard let minutes = timeRemaining, minutes > 0 else { return "--" }
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 {
            return String(localized: "\(h)h \(m)m")
        }
        return String(localized: "\(m) min")
    }
}
