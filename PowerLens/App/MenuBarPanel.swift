import SwiftUI

struct MenuBarPanel: View {
    @Environment(PowerLensViewModel.self) private var vm
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 0) {
            header
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)

            Divider()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    batterySection

                    if !vm.scoredApps.isEmpty {
                        Divider()
                        processSection
                    }

                    if !vm.sleepAssertions.isEmpty {
                        Divider()
                        sleepSection
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .frame(maxHeight: 340)

            Divider()

            footerButtons
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        .frame(width: 300)
        .task {
            vm.start()
        }
        .onDisappear {
            vm.stop()
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title3)
            Text("Power Lens")
                .font(.headline)
            Spacer()
            Button {
                openWindow(id: "main")
            } label: {
                Image(systemName: "macwindow")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help(String(localized: "Open Power Lens"))
        }
    }

    private var batterySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "Battery"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if vm.batteryInfo.isAvailable {
                HStack {
                    Text("\(vm.batteryInfo.percentage)%")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(vm.batteryInfo.isOnBattery
                             ? String(localized: "On Battery")
                             : vm.batteryInfo.isCharging
                             ? String(localized: "Charging")
                             : String(localized: "AC Power"))
                        .font(.caption)
                        .foregroundStyle(vm.batteryInfo.isOnBattery ? Color.primary : Color.green)
                        if let time = vm.batteryInfo.timeRemaining, time > 0 {
                            Text(vm.batteryInfo.timeRemainingFormatted)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if vm.batteryInfo.isLowPowerMode {
                    Label(String(localized: "Low Power Mode"), systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Text(String(localized: "Battery not available"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var processSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "Top Apps"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(Array(vm.scoredApps.prefix(5))) { app in
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(app.appName)
                            .lineLimit(1)
                        Spacer()
                        Text("\(app.powerScore)")
                            .monospacedDigit()
                            .fontWeight(.bold)
                            .foregroundStyle(drainColor(app.drainLevel))
                        Text(String(format: "%.1f%%", app.cpuPercent))
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)

                    if !app.reasonTags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(app.reasonTags, id: \.self) { tag in
                                Text(tag.localizedLabel)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(tagBackgroundColor(app.drainLevel))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if let rec = vm.recommendations[app.id] {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rec.explanation)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ForEach(rec.suggestions.prefix(2), id: \.self) { suggestion in
                                HStack(spacing: 4) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(.yellow)
                                    Text(suggestion)
                                        .font(.caption2)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }
            }
        }
    }

    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "Preventing Sleep"))
                .font(.subheadline)
                .foregroundStyle(.orange)

            ForEach(vm.sleepAssertions) { assertion in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(assertion.appName)
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    Text(assertion.localizedDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(assertion.suggestion)
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
        }
    }

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

    private var footerButtons: some View {
        HStack {
            Spacer()
            Button {
                openSettings()
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.callout)
            .help(String(localized: "Settings"))

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.callout)
            .help(String(localized: "Quit Power Lens"))
        }
    }
}
