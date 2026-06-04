import SwiftUI

enum MainWindowPage: String, CaseIterable, Hashable {
    case overview
    case apps
    case sleep
    case history
    case about

    var localizedLabel: String {
        switch self {
        case .overview: String(localized: "Overview")
        case .apps: String(localized: "Top Apps")
        case .sleep: String(localized: "Sleep")
        case .history: String(localized: "History")
        case .about: String(localized: "About")
        }
    }

    var systemIcon: String {
        switch self {
        case .overview: "gauge.with.dots.needle.33percent"
        case .apps: "list.bullet.clipboard"
        case .sleep: "bed.double"
        case .history: "clock.arrow.circlepath"
        case .about: "info.circle"
        }
    }
}

struct MainWindow: View {
    @Environment(PowerLensViewModel.self) private var vm
    @State private var selectedPage: MainWindowPage = .overview

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPage) {
                Label {
                    Text(MainWindowPage.overview.localizedLabel)
                } icon: {
                    Image(systemName: MainWindowPage.overview.systemIcon)
                }
                .tag(MainWindowPage.overview)

                Label {
                    Text(MainWindowPage.apps.localizedLabel)
                } icon: {
                    Image(systemName: MainWindowPage.apps.systemIcon)
                }
                .tag(MainWindowPage.apps)

                Label {
                    Text(MainWindowPage.sleep.localizedLabel)
                } icon: {
                    Image(systemName: MainWindowPage.sleep.systemIcon)
                }
                .tag(MainWindowPage.sleep)

                Label {
                    Text(MainWindowPage.history.localizedLabel)
                } icon: {
                    Image(systemName: MainWindowPage.history.systemIcon)
                }
                .tag(MainWindowPage.history)

                Divider()

                Label {
                    Text(MainWindowPage.about.localizedLabel)
                } icon: {
                    Image(systemName: MainWindowPage.about.systemIcon)
                }
                .tag(MainWindowPage.about)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(180)
        } detail: {
            detailView(for: selectedPage)
                .environment(vm)
        }
    }

    @ViewBuilder
    private func detailView(for page: MainWindowPage) -> some View {
        switch page {
        case .overview: OverviewPage()
        case .apps: TopAppsPage()
        case .sleep: SleepPage()
        case .history: HistoryPage()
        case .about: AboutPage()
        }
    }
}

// MARK: - Overview

private struct OverviewPage: View {
    @Environment(PowerLensViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                HStack(alignment: .top, spacing: 16) {
                    batteryCard
                    powerStatusCard
                }
                if !vm.scoredApps.isEmpty {
                    quickAppsList
                }
            }
            .padding(24)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Power Lens")
                    .font(.title)
                    .fontWeight(.bold)
                Text(String(localized: "Battery power diagnosis for your Mac"))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if vm.batteryInfo.isAvailable {
                Text("\(vm.batteryInfo.percentage)%")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(batteryColor)
            }
        }
    }

    private var batteryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "Battery"), systemImage: "battery.75percent")
                .font(.headline)
            if vm.batteryInfo.isAvailable {
                LabeledContent(String(localized: "Status"), value: vm.batteryInfo.isOnBattery
                    ? String(localized: "On Battery")
                    : vm.batteryInfo.isCharging
                    ? String(localized: "Charging")
                    : String(localized: "AC Power"))
                LabeledContent(String(localized: "Time Remaining"), value: vm.batteryInfo.timeRemainingFormatted)
                if vm.batteryInfo.isLowPowerMode {
                    Label(String(localized: "Low Power Mode"), systemImage: "leaf.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            } else {
                Text(String(localized: "Battery not available"))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var powerStatusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "Power Status"), systemImage: "bolt.fill")
                .font(.headline)
            if let top = vm.scoredApps.first {
                HStack(spacing: 8) {
                    Circle().fill(drainColor(top.drainLevel)).frame(width: 12, height: 12)
                    Text(top.drainLevel.localizedLabel).fontWeight(.medium)
                }
                Text(String(localized: "Highest drain: \(top.appName) (\(top.powerScore))"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 8) {
                    Circle().fill(.green).frame(width: 12, height: 12)
                    Text(DrainLevel.normal.localizedLabel).fontWeight(.medium)
                }
                Text(String(localized: "No significant power drain detected"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var quickAppsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Top Apps"))
                .font(.headline)
            ForEach(vm.scoredApps.prefix(3)) { app in
                HStack {
                    Circle().fill(drainColor(app.drainLevel)).frame(width: 8, height: 8)
                    Text(app.appName).lineLimit(1)
                    Spacer()
                    Text("\(app.powerScore)")
                        .fontWeight(.bold)
                        .foregroundStyle(drainColor(app.drainLevel))
                    Text(String(format: "%.1f%%", app.cpuPercent))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .font(.callout)
            }
        }
    }

    private var batteryColor: Color {
        guard vm.batteryInfo.isAvailable else { return .secondary }
        if vm.batteryInfo.isCharging { return .green }
        if vm.batteryInfo.percentage > 50 { return .green }
        if vm.batteryInfo.percentage > 20 { return .orange }
        return .red
    }
}

// MARK: - Top Apps

private struct TopAppsPage: View {
    @Environment(PowerLensViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: "Top Apps"))
                    .font(.title2)
                    .fontWeight(.bold)

                ForEach(vm.scoredApps) { app in
                    appRow(app)
                }
            }
            .padding(24)
        }
    }

    private func appRow(_ app: ScoredApp) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle().fill(drainColor(app.drainLevel)).frame(width: 10, height: 10)
                Text(app.appName).fontWeight(.medium)
                Spacer()
                Text("\(app.powerScore)")
                    .fontWeight(.bold)
                    .foregroundStyle(drainColor(app.drainLevel))
                Text(String(format: "%.1f%% CPU", app.cpuPercent))
                    .foregroundStyle(.secondary)
                Text("\(app.memoryMB)MB")
                    .foregroundStyle(.secondary)
            }

            if !app.reasonTags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(app.reasonTags, id: \.self) { tag in
                        Text(tag.localizedLabel)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tagBackgroundColor(app.drainLevel))
                            .clipShape(Capsule())
                    }
                }
            }

            if let rec = vm.recommendations[app.id] {
                Text(rec.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(rec.suggestions, id: \.self) { suggestion in
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.yellow)
                        Text(suggestion).font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Sleep

private struct SleepPage: View {
    @Environment(PowerLensViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: "Preventing Sleep"))
                    .font(.title2)
                    .fontWeight(.bold)

                if vm.sleepAssertions.isEmpty {
                    Label(String(localized: "No apps preventing sleep"), systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                ForEach(vm.sleepAssertions) { assertion in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(assertion.appName).fontWeight(.medium)
                        }
                        Text(assertion.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(assertion.suggestion)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(24)
        }
    }
}

// MARK: - History (placeholder)

private struct HistoryPage: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(String(localized: "History coming soon"))
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - About

private struct AboutPage: View {
    @Environment(\.openURL) private var openURL

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                if let nsImage = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128, height: 128)
                }

                Text("Power Lens")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Text(String(localized: "Version \(appVersion) (\(buildVersion))"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("© 2024–2026 Power Lens Contributors. GPLv3")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Text(String(localized: "Battery power diagnosis for your Mac"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(String(localized: "GitHub")) {
                    if let url = URL(string: "https://github.com/wwek/power-lens") {
                        openURL(url)
                    }
                }
                Button(String(localized: "Report a Bug")) {
                    if let url = URL(string: "https://github.com/wwek/power-lens/issues") {
                        openURL(url)
                    }
                }
                Button(String(localized: "License")) {
                    if let url = URL(string: "https://www.gnu.org/licenses/gpl-3.0.en.html") {
                        openURL(url)
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shared helpers

private func drainColor(_ level: DrainLevel) -> Color {
    switch level {
    case .normal: return .green
    case .moderate: return .yellow
    case .high: return .orange
    case .abnormal: return .red
    }
}

private func tagBackgroundColor(_ level: DrainLevel) -> Color {
    switch level {
    case .normal: return .green.opacity(0.15)
    case .moderate: return .yellow.opacity(0.15)
    case .high: return .orange.opacity(0.15)
    case .abnormal: return .red.opacity(0.15)
    }
}
