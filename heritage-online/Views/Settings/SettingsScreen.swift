import SwiftUI

struct SettingsScreen: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @Binding var themeMode: AppThemeMode
    @Binding var languageMode: AppLanguageMode
    let onBack: () -> Void
    var onMyPageClick: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    HeritagePageHeader(title: loc.localized("nav_settings"))
                    Spacer()
                }
                .padding(.top, 8)

                HeritageContentCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(loc.localized("settings_theme"))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Picker(loc.localized("settings_theme"), selection: $themeMode) {
                            ForEach(AppThemeMode.allCases, id: \.self) { mode in
                                Text(loc.localized(mode.labelKey)).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(18)
                }
                .padding(.horizontal, 20)

                HeritageContentCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(loc.localized("settings_language"))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Picker(loc.localized("settings_language"), selection: $languageMode) {
                            ForEach(AppLanguageMode.allCases, id: \.self) { mode in
                                Text(loc.localized(mode.labelKey)).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(18)
                }
                .padding(.horizontal, 20)

                HeritageContentCard {
                        VStack(alignment: .leading, spacing: 14) {
                        Text(loc.localized("nav_my"))
                            .font(.title3)
                            .fontWeight(.semibold)

                        Button {
                            onMyPageClick?()
                        } label: {
                            HStack {
                                Label("my_favorites", systemImage: "heart")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)

                        Divider()

                        Button {
                            onMyPageClick?()
                        } label: {
                            HStack {
                                Label("my_recent", systemImage: "clock")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(18)
                }
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
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button("action_back") {
                    onBack()
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button("action_back") {
                    onBack()
                }
            }
            #endif
        }
    }
}
