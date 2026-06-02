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

struct HeritageThemeModifier: ViewModifier {
    @Environment(SettingsManager.self) private var settingsManager

    func body(content: Content) -> some View {
        let colorScheme = resolveColorScheme()

        content
            .environment(\.heritageColorScheme, colorScheme)
            .background(colorScheme.background)
            .tint(colorScheme.primary)
    }

    private func resolveColorScheme() -> HeritageColorScheme {
        switch settingsManager.themeMode {
        case .system:
            // 在实际实现中，需要检测系统明暗模式
            // 这里暂时使用浅色，后续会改进
            return .light
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

extension View {
    /// 应用 Heritage 主题
    func heritageTheme() -> some View {
        modifier(HeritageThemeModifier())
    }
}

// MARK: - Convenience Extensions

extension View {
    /// 使用 Heritage 颜色方案中的主色调
    func heritagePrimary() -> some View {
        self.environment(\.colorScheme, .light) // 占位，后续完善
    }
}
