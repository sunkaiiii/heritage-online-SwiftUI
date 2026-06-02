import SwiftUI

// MARK: - Environment Key

private struct HeritageColorSchemeKey: EnvironmentKey {
    static let defaultValue = HeritageColorScheme.light
}

extension EnvironmentValues {
    /// 当前 Heritage 颜色方案
    var heritageColorScheme: HeritageColorScheme {
        get { self[HeritageColorSchemeKey.self] }
        set { self[HeritageColorSchemeKey.self] = newValue }
    }
}

// MARK: - Theme View Modifier

/// Heritage 主题修饰符
/// 根据设置和系统模式自动切换浅色/暗色
struct HeritageThemeModifier: ViewModifier {
    let settingsManager: SettingsManager
    @Environment(\.colorScheme) private var systemColorScheme

    func body(content: Content) -> some View {
        let colorScheme = resolveColorScheme()

        content
            .environment(\.heritageColorScheme, colorScheme)
            .background(colorScheme.background)
            .tint(colorScheme.primary)
    }

    /// 根据主题设置解析当前应使用的颜色方案
    private func resolveColorScheme() -> HeritageColorScheme {
        switch settingsManager.themeMode {
        case .system:
            // 跟随系统明暗模式
            return systemColorScheme == .dark ? .dark : .light
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

extension View {
    /// 应用 Heritage 主题
    func heritageTheme(settingsManager: SettingsManager = .shared) -> some View {
        modifier(HeritageThemeModifier(settingsManager: settingsManager))
    }
}
