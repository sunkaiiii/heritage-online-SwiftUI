import SwiftUI

/// 筛选按钮组件
/// 图标按钮 + badge
struct FilterButton: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let activeCount: Int
    let action: () -> Void

    init(activeCount: Int = 0, action: @escaping () -> Void) {
        self.activeCount = activeCount
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(colorScheme.onSurfaceVariant)

                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(colorScheme.primary)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        FilterButton(activeCount: 0, action: {})
        FilterButton(activeCount: 2, action: {})
        FilterButton(activeCount: 5, action: {})
    }
    .environment(\.heritageColorScheme, .light)
}
