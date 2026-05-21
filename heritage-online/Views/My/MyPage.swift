import SwiftUI

struct MyPage: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        FavoritesView()
                    } label: {
                        Label(String(localized: "my_favorites"), systemImage: "heart.fill")
                    }

                    NavigationLink {
                        RecentView()
                    } label: {
                        Label(String(localized: "my_recent"), systemImage: "clock")
                    }
                }

                Section {
                    HStack {
                        Label(String(localized: "my_about"), systemImage: "info.circle")
                        Spacer()
                        Text("v0.1.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(String(localized: "nav_my"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "action_back")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FavoritesView: View {
    var body: some View {
        List {
            ContentUnavailableView(
                String(localized: "my_favorites_empty"),
                systemImage: "heart.slash",
                description: Text(String(localized: "my_favorites_empty_message"))
            )
        }
        .navigationTitle(String(localized: "my_favorites"))
    }
}

struct RecentView: View {
    var body: some View {
        List {
            ContentUnavailableView(
                String(localized: "my_recent_empty"),
                systemImage: "clock.badge.questionmark",
                description: Text(String(localized: "my_recent_empty_message"))
            )
        }
        .navigationTitle(String(localized: "my_recent"))
    }
}
