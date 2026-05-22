import SwiftUI

struct MyPage: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    HeritagePageHeader(title: loc.localized("nav_my"))
                    Spacer()
                }
                .padding(.top, 8)

                HeritageContentCard(onClick: {}) {
                    HStack {
                        Label("my_favorites", systemImage: "heart")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(18)
                }
                .padding(.horizontal, 20)

                HeritageContentCard(onClick: {}) {
                    HStack {
                        Label("my_recent", systemImage: "clock")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
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
        .navigationTitle("nav_my")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
