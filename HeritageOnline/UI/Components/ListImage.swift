import SwiftUI

/// 列表图片组件
/// 有 URL 用 AsyncImage，无 URL 用 placeholder
struct ListImage: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let url: URL?
    let title: String
    let width: CGFloat?
    let height: CGFloat

    init(url: URL?, title: String, width: CGFloat? = 100, height: CGFloat = 80) {
        self.url = url
        self.title = title
        self.width = width
        self.height = height
    }

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                case .failure:
                    ImagePlaceholder(label: title, width: width, height: height)
                case .empty:
                    ProgressView()
                        .frame(width: width, height: height)
                @unknown default:
                    ImagePlaceholder(label: title, width: width, height: height)
                }
            }
        } else {
            ImagePlaceholder(label: title, width: width, height: height)
        }
    }
}

#Preview {
    ListImage(url: nil, title: "测试标题")
        .environment(\.heritageColorScheme, .light)
}
