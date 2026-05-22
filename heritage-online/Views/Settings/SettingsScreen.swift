import SwiftUI

struct SettingsScreen: View {
    @Environment(ThemeManager.self) private var theme
    @Binding var themeMode: AppThemeMode
    @Binding var languageMode: AppLanguageMode
    let onBack: () -> Void
    var onMyPageClick: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    HeritagePageHeader(title: String(localized: "nav_settings"))
                    Spacer()
                }
                .padding(.top, 8)

                HeritageContentCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(String(localized: "settings_theme"))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Picker(String(localized: "settings_theme"), selection: $themeMode) {
                            ForEach(AppThemeMode.allCases, id: \.self) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(18)
                }
                .padding(.horizontal, 20)

                HeritageContentCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(String(localized: "settings_language"))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Picker(String(localized: "settings_language"), selection: $languageMode) {
                            ForEach(AppLanguageMode.allCases, id: \.self) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(18)
                }
                .padding(.horizontal, 20)

                HeritageContentCard {
                        VStack(alignment: .leading, spacing: 14) {
                        Text(String(localized: "nav_my"))
                            .font(.title3)
                            .fontWeight(.semibold)

                        Button {
                            onMyPageClick?()
                        } label: {
                            HStack {
                                Label(String(localized: "my_favorites"), systemImage: "heart")
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
                                Label(String(localized: "my_recent"), systemImage: "clock")
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
                        Text(String(localized: "settings_about"))
                            .font(.title3)
                            .fontWeight(.semibold)
                        HStack {
                            Text(String(localized: "my_about"))
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
                Button(String(localized: "action_back")) {
                    onBack()
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button(String(localized: "action_back")) {
                    onBack()
                }
            }
            #endif
        }
    }
}
