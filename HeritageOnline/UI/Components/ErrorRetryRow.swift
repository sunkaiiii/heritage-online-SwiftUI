import SwiftUI

/// 错误重试行组件
struct ErrorRetryRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let messageKey: LocalizedStringKey
    let retryAction: () -> Void

    init(message: LocalizedStringKey = "error.unknown", retryAction: @escaping () -> Void) {
        self.messageKey = message
        self.retryAction = retryAction
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 16))
                .foregroundStyle(colorScheme.error)

            Text(messageKey)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Spacer()

            Button(action: retryAction) {
                Text("action.retry")
                    .font(HeritageTypography.labelLarge)
                    .foregroundStyle(colorScheme.primary)
            }
        }
        .padding(12)
        .background(colorScheme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }
}

// MARK: - Error Color Extension

extension HeritageColorScheme {
    /// 错误颜色（用于错误状态）
    var error: Color {
        Color(hex: "BA1A1A")
    }

    var errorContainer: Color {
        Color(hex: "FFDAD6")
    }

    var onError: Color {
        .white
    }

    var onErrorContainer: Color {
        Color(hex: "410002")
    }
}

#Preview {
    ErrorRetryRow(message: "网络连接错误", retryAction: {})
        .padding(20)
        .environment(\.heritageColorScheme, .light)
}
