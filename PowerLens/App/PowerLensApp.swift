import SwiftUI

@main
struct PowerLensApp: App {
    @State private var viewModel = PowerLensViewModel()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            MenuBarPanel()
                .environment(viewModel)
        } label: {
            statusBarIcon
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 320, height: 480)

        Window("Power Lens", id: "main") {
            MainWindow()
                .environment(viewModel)
        }
        .defaultSize(width: 640, height: 520)
    }

    @ViewBuilder
    private var statusBarIcon: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "bolt.circle.fill")
            Circle()
                .fill(statusDotColor)
                .frame(width: 7, height: 7)
        }
    }

    private var statusDotColor: Color {
        if !viewModel.batteryInfo.isAvailable { return .gray }
        if viewModel.batteryInfo.isCharging { return .blue }

        let maxScore = viewModel.scoredApps.map(\.powerScore).max() ?? 0
        switch maxScore {
        case 0..<30: return .green
        case 30..<60: return .yellow
        case 60..<80: return .orange
        default: return .red
        }
    }
}
