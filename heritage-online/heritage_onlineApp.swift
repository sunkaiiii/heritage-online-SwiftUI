import SwiftUI

@main
struct heritage_onlineApp: App {
    @AppStorage("theme_mode") private var themeMode: String = AppThemeMode.system.rawValue
    @AppStorage("language_mode") private var languageMode: String = AppLanguageMode.system.rawValue

    @State private var themeManager = ThemeManager()
    @State private var locManager = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            AppRoot(
                themeMode: Binding(
                    get: { AppThemeMode(rawValue: themeMode) ?? .system },
                    set: { themeMode = $0.rawValue }
                ),
                languageMode: Binding(
                    get: { AppLanguageMode(rawValue: languageMode) ?? .system },
                    set: { languageMode = $0.rawValue }
                ),
                themeManager: themeManager,
                locManager: locManager
            )
        }
    }
}

struct AppRoot: View {
    @Binding var themeMode: AppThemeMode
    @Binding var languageMode: AppLanguageMode
    var themeManager: ThemeManager
    var locManager: LocalizationManager
    @Environment(\.colorScheme) private var systemColorScheme

    private var resolvedLanguage: String {
        switch languageMode {
        case .system: return Locale.current.language.languageCode?.identifier ?? "en"
        case .simplifiedChinese: return "zh-Hans"
        case .english: return "en"
        }
    }

    private var resolvedLocale: Locale {
        switch languageMode {
        case .system: return .current
        case .simplifiedChinese: return Locale(identifier: "zh-Hans")
        case .english: return Locale(identifier: "en")
        }
    }

    private var resolvedColorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var body: some View {
        ContentView()
            .environment(themeManager)
            .environment(locManager)
            .preferredColorScheme(resolvedColorScheme)
            .onAppear { syncAll() }
            .onChange(of: themeMode) { _, _ in syncAll() }
            .onChange(of: languageMode) { _, _ in syncAll() }
            .onChange(of: systemColorScheme) { _, _ in syncAll() }
    }

    private func syncAll() {
        themeManager.update(mode: themeMode, systemIsDark: systemColorScheme == .dark)
        locManager.setLanguage(resolvedLanguage)
    }
}
