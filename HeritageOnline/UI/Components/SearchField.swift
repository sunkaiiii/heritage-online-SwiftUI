import SwiftUI

/// 搜索输入框组件
struct SearchField: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @Binding var text: String
    let placeholderKey: LocalizedStringKey
    let onSubmit: (() -> Void)?

    init(
        text: Binding<String>,
        placeholder: LocalizedStringKey = "nav.search",
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholderKey = placeholder
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            TextField(placeholderKey, text: $text)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurface)
                .textFieldStyle(.plain)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(colorScheme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchField(text: $text, placeholder: "搜索文章")
        .padding(20)
        .environment(\.heritageColorScheme, .light)
}
