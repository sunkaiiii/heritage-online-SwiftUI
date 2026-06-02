import SwiftUI

/// 应用主视图
struct ContentView: View {
    @Environment(SettingsManager.self) private var settingsManager

    var body: some View {
        @Bindable var settings = settingsManager

        TabView {
            ArticlesTab()
                .tabItem {
                    Label(String(localized: "tab.articles"), systemImage: "newspaper")
                }

            DirectoryTab()
                .tabItem {
                    Label(String(localized: "tab.directory"), systemImage: "book.closed")
                }

            InheritorsTab()
                .tabItem {
                    Label(String(localized: "tab.inheritors"), systemImage: "person.3")
                }

            DiscoveryTab()
                .tabItem {
                    Label(String(localized: "tab.discovery"), systemImage: "safari")
                }
        }
        .tint(HeritageColors.primaryLight) // TODO: 根据主题动态切换
    }
}

// MARK: - Tab Views (占位)

/// 文章 Tab
struct ArticlesTab: View {
    var body: some View {
        NavigationStack {
            Text(String(localized: "page.articles"))
                .font(HeritageTypography.headlineLarge)
                .navigationTitle(String(localized: "tab.articles"))
        }
    }
}

/// 名录 Tab
struct DirectoryTab: View {
    var body: some View {
        NavigationStack {
            Text(String(localized: "page.directory"))
                .font(HeritageTypography.headlineLarge)
                .navigationTitle(String(localized: "tab.directory"))
        }
    }
}

/// 传承人 Tab
struct InheritorsTab: View {
    var body: some View {
        NavigationStack {
            Text(String(localized: "page.inheritors"))
                .font(HeritageTypography.headlineLarge)
                .navigationTitle(String(localized: "tab.inheritors"))
        }
    }
}

/// 发现 Tab
struct DiscoveryTab: View {
    var body: some View {
        NavigationStack {
            Text(String(localized: "page.discovery"))
                .font(HeritageTypography.headlineLarge)
                .navigationTitle(String(localized: "tab.discovery"))
        }
    }
}

#Preview {
    ContentView()
        .environment(SettingsManager.shared)
}
