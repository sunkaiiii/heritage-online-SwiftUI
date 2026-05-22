import SwiftUI

struct MyPage: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    let onBack: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        HeritagePageHeader(title: loc.localized("nav_my"))
                        Spacer()
                        Button(action: onBack) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    NavigationLink {
                        FavoritesView()
                    } label: {
                        HeritageContentCard {
                            HStack {
                                Label(loc.localized("my_favorites"), systemImage: "heart")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(18)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    NavigationLink {
                        RecentView()
                    } label: {
                        HeritageContentCard {
                            HStack {
                                Label(loc.localized("my_recent"), systemImage: "clock")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(18)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    HeritageContentCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(loc.localized("settings_about"))
                                .font(.title3)
                                .fontWeight(.semibold)
                            HStack {
                                Text(loc.localized("my_about"))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("v0.1.0")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(18)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
            .background(theme.background)
        }
    }
}

struct FavoritesView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeritagePageHeader(title: loc.localized("my_favorites"))
                    .padding(.top, 8)

                ContentUnavailableView(
                    loc.localized("my_favorites_empty"),
                    systemImage: "heart.slash",
                    description: Text(loc.localized("my_favorites_empty_message"))
                )
                .padding(.top, 40)
            }
            .padding(.bottom, 30)
        }
        .background(theme.background)
        .navigationTitle(loc.localized("my_favorites"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct RecentView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeritagePageHeader(title: loc.localized("my_recent"))
                    .padding(.top, 8)

                ContentUnavailableView(
                    loc.localized("my_recent_empty"),
                    systemImage: "clock.badge.questionmark",
                    description: Text(loc.localized("my_recent_empty_message"))
                )
                .padding(.top, 40)
            }
            .padding(.bottom, 30)
        }
        .background(theme.background)
        .navigationTitle(loc.localized("my_recent"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
