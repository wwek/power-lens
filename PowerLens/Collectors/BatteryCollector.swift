import Foundation
import IOKit
import IOKit.ps

final class BatteryCollector {
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.powerlens.battery", qos: .utility)
    private var callback: (@Sendable (BatteryInfo) -> Void)?

    func start(interval: TimeInterval = 3.0, onUpdate: @escaping @Sendable (BatteryInfo) -> Void) {
        self.callback = onUpdate
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval, leeway: .seconds(1))
        timer.setEventHandler { [weak self] in
            let info = self?.collect() ?? .unavailable
            onUpdate(info)
        }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func collect() -> BatteryInfo {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty else {
            return .unavailable
        }

        for source in sources {
            guard let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else {
                continue
            }

            let percentage = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
            let state = desc[kIOPSPowerSourceStateKey] as? String ?? ""
            let isCharging = desc[kIOPSIsChargingKey] as? Bool ?? false
            let timeRemaining = desc[kIOPSTimeToEmptyKey] as? Int ?? desc[kIOPSTimeToFullChargeKey] as? Int ?? -1
            let isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled

            return BatteryInfo(
                percentage: percentage,
                isCharging: isCharging,
                isOnBattery: state == "Battery Power",
                timeRemaining: timeRemaining > 0 ? timeRemaining : nil,
                isLowPowerMode: isLowPower,
                isAvailable: true
            )
        }

        return .unavailable
    }
}
