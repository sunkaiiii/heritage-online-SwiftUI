import SwiftUI

struct HeritageSearchField: View {
    @Environment(ThemeManager.self) private var theme
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(theme.onSurface)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(theme.surfaceContainer)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.outlineVariant, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 20)
    }
}
