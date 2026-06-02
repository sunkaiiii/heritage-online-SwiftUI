import SwiftUI

/// 空状态组件
struct EmptyState: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let icon: String
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey?

    init(icon: String = "tray", title: LocalizedStringKey = "empty.noContent", message: LocalizedStringKey? = nil) {
        self.icon = icon
        self.titleKey = title
        self.messageKey = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(titleKey)
                .font(HeritageTypography.titleMedium)
                .foregroundStyle(colorScheme.onSurface)

            if let messageKey {
                Text(messageKey)
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    EmptyState(
        icon: "doc.text.magnifyingglass",
        title: "暂无内容",
        message: "尝试不同的搜索条件"
    )
    .environment(\.heritageColorScheme, .light)
}
