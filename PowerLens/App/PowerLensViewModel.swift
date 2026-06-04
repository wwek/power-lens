import SwiftUI

@Observable
@MainActor
final class PowerLensViewModel {
    var batteryInfo = BatteryInfo.unavailable
    var scoredApps: [ScoredApp] = []
    var recommendations: [String: Recommendation] = [:]
    var sleepAssertions: [SleepAssertionInfo] = []

    private let batteryCollector = BatteryCollector()
    private let processCollector = ProcessCollector()
    private let sleepCollector = SleepAssertionCollector()
    private let scorer = PowerScorer()
    private let recommender = RecommendationEngine()
    private let settings = AppSettings.shared

    func start() {
        batteryCollector.start(interval: 3.0) { [weak self] info in
            Task { @MainActor in
                self?.batteryInfo = info
            }
        }

        processCollector.start(interval: settings.collectionInterval) { [weak self] apps in
            Task { @MainActor [scorer = self!.scorer, recommender = self!.recommender] in
                let isOnBattery = self?.batteryInfo.isOnBattery ?? false
                let scored = scorer.score(apps: apps, isOnBattery: isOnBattery)
                let top5 = Array(scored.prefix(5))
                self?.scoredApps = top5

                var recs: [String: Recommendation] = [:]
                for app in top5 where app.powerScore >= 30 {
                    if let rec = recommender.generate(for: app) {
                        recs[app.id] = rec
                    }
                }
                self?.recommendations = recs
            }
        }

        sleepCollector.start(interval: 30.0) { [weak self] assertions in
            Task { @MainActor in
                self?.sleepAssertions = assertions
            }
        }
    }

    func stop() {
        batteryCollector.stop()
        processCollector.stop()
        sleepCollector.stop()
    }
}
