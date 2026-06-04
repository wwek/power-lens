import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        TabView {
            GeneralSettingsTab(settings: settings)
                .tabItem {
                    Label(String(localized: "General"), systemImage: "gear")
                }
            AboutSettingsTab()
                .tabItem {
                    Label(String(localized: "About"), systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 380)
    }
}

// MARK: - General Tab

private struct GeneralSettingsTab: View {
    @Bindable var settings: AppSettings

    private let intervalOptions: [(String, TimeInterval)] = [
        ("3s", 3.0),
        ("5s", 5.0),
        ("10s", 10.0),
        ("30s", 30.0),
    ]

    private let retentionOptions: [(String, Int)] = [
        ("1 day", 1),
        ("3 days", 3),
        ("7 days", 7),
        ("14 days", 14),
    ]

    var body: some View {
        Form {
            Section(String(localized: "General")) {
                Toggle(String(localized: "Launch at Login"), isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            settings.launchAtLogin = !newValue
                        }
                    }
            }

            Section(String(localized: "Collection")) {
                Picker(String(localized: "Collection Interval"), selection: $settings.collectionInterval) {
                    ForEach(intervalOptions, id: \.1) { label, value in
                        Text(label).tag(value)
                    }
                }
            }

            Section(String(localized: "Alerts")) {
                Picker(String(localized: "Low Battery Threshold"), selection: $settings.lowBatteryThreshold) {
                    ForEach(10...50, id: \.self) { val in
                        Text("\(val)%").tag(val)
                    }
                }
            }

            Section(String(localized: "History")) {
                Picker(String(localized: "Retention"), selection: $settings.historyRetentionDays) {
                    ForEach(retentionOptions, id: \.1) { label, value in
                        Text(String(localized: "\(label)")).tag(value)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - About Tab

private struct AboutSettingsTab: View {
    @Environment(\.openURL) private var openURL

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var copyright: String {
        "© 2024–2026 Power Lens Contributors. GPLv3"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            appInfoSection

            Spacer()

            bottomBar
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            if let nsImage = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
            }

            Text("Power Lens")
                .font(.title)
                .fontWeight(.semibold)

            Text(String(localized: "Version \(appVersion) (\(buildVersion))"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(copyright)
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text(String(localized: "Battery power diagnosis for your Mac"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private var bottomBar: some View {
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
        .controlSize(.small)
    }
}
