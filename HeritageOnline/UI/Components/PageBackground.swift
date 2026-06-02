import SwiftUI

/// 页面背景组件
/// 确保每页背景一致
struct PageBackground<Content: View>: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .background(colorScheme.background)
            .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    PageBackground {
        Text("Page Content")
    }
    .environment(\.heritageColorScheme, .light)
}
