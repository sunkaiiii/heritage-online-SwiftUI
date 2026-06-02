import SwiftUI

/// 统一图片加载组件
/// 对齐 Android Coil AsyncImage
/// 支持 URL 为空时显示占位、加载失败占位
struct HeritageAsyncImage: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 图片 URL
    let urlString: String?

    /// 占位文本（通常是标题首字）
    let placeholderText: String

    /// 内容模式
    let contentMode: ContentMode

    /// 是否允许点击预览
    let onTap: (() -> Void)?

    init(
        urlString: String?,
        placeholderText: String? = nil,
        contentMode: ContentMode = .fill,
        onTap: (() -> Void)? = nil
    ) {
        self.urlString = urlString
        self.placeholderText = placeholderText ?? "E"
        self.contentMode = contentMode
        self.onTap = onTap
    }

    /// 从 MediaAssetDTO 初始化
    /// 使用 ImagePreviewUrl.listUrl 选择 URL
    init(
        asset: MediaAssetDTO?,
        placeholderText: String? = nil,
        contentMode: ContentMode = .fill,
        onTap: (() -> Void)? = nil
    ) {
        self.urlString = ImagePreviewUrl.listUrl(from: asset)
        self.placeholderText = placeholderText ?? "E"
        self.contentMode = contentMode
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let urlString, !urlString.isEmpty, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)

                    case .failure:
                        imagePlaceholder

                    case .empty:
                        loadingPlaceholder

                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius)
                .stroke(colorScheme.outlineVariant, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // 只在有有效 URL 时触发预览
            if urlString != nil, !(urlString?.isEmpty ?? true) {
                onTap?()
            }
        }
    }

    /// 图片占位
    private var imagePlaceholder: some View {
        ZStack {
            colorScheme.surfaceContainerHigh

            Text(placeholderText)
                .font(HeritageTypography.labelLarge)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme.onSurfaceVariant.opacity(0.82))
        }
    }

    /// 加载中占位
    private var loadingPlaceholder: some View {
        ZStack {
            colorScheme.surfaceContainerHigh

            ProgressView()
                .tint(colorScheme.primary)
        }
    }
}

// MARK: - 列表图片组件

/// 列表图片组件
/// 对齐 Android HeritageListImage
struct HeritageListImage: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 图片 URL
    let urlString: String?

    /// 占位文本
    let placeholderText: String

    /// 宽度
    let width: CGFloat?

    /// 高度
    let height: CGFloat

    /// 是否允许点击预览
    let onTap: (() -> Void)?

    init(
        urlString: String?,
        placeholderText: String? = nil,
        width: CGFloat? = 100,
        height: CGFloat = 80,
        onTap: (() -> Void)? = nil
    ) {
        self.urlString = urlString
        self.placeholderText = placeholderText ?? "E"
        self.width = width
        self.height = height
        self.onTap = onTap
    }

    /// 从 MediaAssetDTO 初始化
    init(
        asset: MediaAssetDTO?,
        placeholderText: String? = nil,
        width: CGFloat? = 100,
        height: CGFloat = 80,
        onTap: (() -> Void)? = nil
    ) {
        self.urlString = ImagePreviewUrl.listUrl(from: asset)
        self.placeholderText = placeholderText ?? "E"
        self.width = width
        self.height = height
        self.onTap = onTap
    }

    var body: some View {
        HeritageAsyncImage(
            urlString: urlString,
            placeholderText: placeholderText,
            contentMode: .fill,
            onTap: onTap
        )
        .frame(width: width, height: height)
    }
}

// MARK: - 详情图片组件

/// 详情图片组件
/// 对齐 Android HeritageDetailImage
struct HeritageDetailImage: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 图片 URL
    let urlString: String?

    /// 占位文本
    let placeholderText: String

    /// 内容模式
    let contentMode: ContentMode

    /// 是否允许点击预览
    let onTap: (() -> Void)?

    init(
        urlString: String?,
        placeholderText: String? = nil,
        contentMode: ContentMode = .fit,
        onTap: (() -> Void)? = nil
    ) {
        self.urlString = urlString
        self.placeholderText = placeholderText ?? "E"
        self.contentMode = contentMode
        self.onTap = onTap
    }

    /// 从 MediaAssetDTO 初始化
    init(
        asset: MediaAssetDTO?,
        placeholderText: String? = nil,
        contentMode: ContentMode = .fit,
        onTap: (() -> Void)? = nil
    ) {
        self.urlString = ImagePreviewUrl.previewUrl(from: asset)
        self.placeholderText = placeholderText ?? "E"
        self.contentMode = contentMode
        self.onTap = onTap
    }

    var body: some View {
        HeritageAsyncImage(
            urlString: urlString,
            placeholderText: placeholderText,
            contentMode: contentMode,
            onTap: onTap
        )
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
    }
}

#Preview {
    VStack(spacing: 16) {
        HeritageListImage(
            urlString: nil,
            placeholderText: "测试"
        )

        HeritageDetailImage(
            urlString: nil,
            placeholderText: "详情图"
        )
    }
    .padding(20)
    .environment(\.heritageColorScheme, .light)
}
