import SwiftUI

/// 页面头部组件
/// 横向 Row，左侧 title/subtitle，右侧 actions
struct PageHeader: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey?
    let actions: [PageHeaderAction]

    struct PageHeaderAction: Identifiable {
        let id = UUID()
        let icon: String
        let accessibilityLabelKey: LocalizedStringKey
        let action: () -> Void

        init(icon: String, accessibilityLabelKey: LocalizedStringKey, action: @escaping () -> Void) {
            self.icon = icon
            self.accessibilityLabelKey = accessibilityLabelKey
            self.action = action
        }
    }

    init(titleKey: LocalizedStringKey, subtitleKey: LocalizedStringKey? = nil, actions: [PageHeaderAction] = []) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.actions = actions
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey)
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                if let subtitleKey {
                    Text(subtitleKey)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                ForEach(actions) { action in
                    Button(action: action.action) {
                        Image(systemName: action.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                    .accessibilityLabel(action.accessibilityLabelKey)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
}

#Preview {
    PageHeader(
        titleKey: "app.name",
        subtitleKey: "page.articles.subtitle",
        actions: [
            .init(icon: "gear", accessibilityLabelKey: "nav.settings", action: {}),
            .init(icon: "arrow.clockwise", accessibilityLabelKey: "action.refresh", action: {})
        ]
    )
    .environment(\.heritageColorScheme, .light)
}
