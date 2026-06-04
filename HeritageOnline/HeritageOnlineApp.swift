import SwiftUI

@main
struct HeritageOnlineApp: App {
    /// 设置管理器
    @State private var settingsManager = SettingsManager.shared

    /// 应用依赖容器
    @State private var dependencies = AppDependencies.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settingsManager)
                .environment(dependencies)
                .heritageTheme(settingsManager: settingsManager)
                .environment(\.locale, settingsManager.locale ?? .autoupdatingCurrent)
                .preferredColorScheme(settingsManager.colorScheme)
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}
