import SwiftUI

/// 页面头部组件
/// 横向 Row，左侧 title/subtitle，右侧 actions
struct PageHeader: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let title: String
    let subtitle: String?
    let actions: [PageHeaderAction]

    struct PageHeaderAction: Identifiable {
        let id = UUID()
        let icon: String
        let accessibilityLabel: String
        let action: () -> Void

        init(icon: String, accessibilityLabel: String? = nil, action: @escaping () -> Void) {
            self.icon = icon
            self.accessibilityLabel = accessibilityLabel ?? icon
            self.action = action
        }
    }

    init(title: String, subtitle: String? = nil, actions: [PageHeaderAction] = []) {
        self.title = title
        self.subtitle = subtitle
        self.actions = actions
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                if let subtitle {
                    Text(subtitle)
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
                    .accessibilityLabel(action.accessibilityLabel)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
}

#Preview {
    PageHeader(
        title: String(localized: "app.name"),
        subtitle: String(localized: "page.articles.subtitle"),
        actions: [
            .init(icon: "gear", accessibilityLabel: String(localized: "nav.settings"), action: {}),
            .init(icon: "arrow.clockwise", accessibilityLabel: String(localized: "action.refresh"), action: {})
        ]
    )
    .environment(\.heritageColorScheme, .light)
}
