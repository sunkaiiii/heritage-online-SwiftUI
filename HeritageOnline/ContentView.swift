import SwiftUI

/// 应用主视图
struct ContentView: View {
    @Environment(SettingsManager.self) private var settingsManager

    var body: some View {
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
        .heritageTheme()
    }
}

// MARK: - Tab Views (占位)

/// 文章 Tab
struct ArticlesTab: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack {
                    PageHeader(
                        title: "E迹",
                        subtitle: "非遗新闻、论坛与专题",
                        actions: [
                            .init(icon: "gear") {
                                // TODO: 进入设置
                            }
                        ]
                    )

                    Spacer()

                    Text(String(localized: "page.articles"))
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "tab.articles"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

/// 名录 Tab
struct DirectoryTab: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack {
                    Spacer()

                    Text(String(localized: "page.directory"))
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "tab.directory"))
        }
    }
}

/// 传承人 Tab
struct InheritorsTab: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack {
                    Spacer()

                    Text(String(localized: "page.inheritors"))
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "tab.inheritors"))
        }
    }
}

/// 发现 Tab
struct DiscoveryTab: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack {
                    Spacer()

                    Text(String(localized: "page.discovery"))
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "tab.discovery"))
        }
    }
}

#Preview {
    ContentView()
        .environment(SettingsManager.shared)
        .environment(\.heritageColorScheme, .light)
}
