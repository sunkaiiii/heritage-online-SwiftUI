import SwiftUI

struct SettingsScreen: View {
    @Binding var themeMode: AppThemeMode
    @Binding var languageMode: AppLanguageMode
    let onBack: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(String(localized: "settings_theme"), selection: $themeMode) {
                        ForEach(AppThemeMode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                }

                Section {
                    Picker(String(localized: "settings_language"), selection: $languageMode) {
                        ForEach(AppLanguageMode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                }

                Section {
                    NavigationLink {
                        MyPage()
                    } label: {
                        Label(String(localized: "nav_my"), systemImage: "person.circle")
                    }
                }

                Section {
                    HStack {
                        Label(String(localized: "settings_about"), systemImage: "info.circle")
                        Spacer()
                        Text("v0.1.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(String(localized: "nav_settings"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
}
