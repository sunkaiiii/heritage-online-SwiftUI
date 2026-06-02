import SwiftUI

/// 图片预览覆盖层
/// 完全对齐 Android ImagePreviewOverlay
/// 支持多图、关闭、缩放、页码显示
struct ImagePreviewOverlay: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 图片 URL 列表
    let imageUrls: [String]

    /// 初始显示的图片索引
    let initialIndex: Int

    /// 关闭回调
    let onDismiss: () -> Void

    /// 当前页码
    @State private var currentPage: Int

    /// 缩放比例
    @State private var scale: CGFloat = 1.0

    /// 拖拽偏移
    @State private var offset: CGSize = .zero

    init(
        imageUrls: [String],
        initialIndex: Int = 0,
        onDismiss: @escaping () -> Void
    ) {
        self.imageUrls = imageUrls
        self.initialIndex = initialIndex
        self.onDismiss = onDismiss
        self._currentPage = State(initialValue: initialIndex)
    }

    var body: some View {
        if imageUrls.isEmpty {
            EmptyView()
        } else {
            ZStack {
                // 背景
                Color.black.opacity(0.96)
                    .ignoresSafeArea()

                // 图片内容
                TabView(selection: $currentPage) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, urlString in
                        if let url = URL(string: urlString) {
                            ZoomableImageView(url: url)
                                .tag(index)
                        }
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif

                // 顶部工具栏
                VStack {
                    HStack {
                        // 关闭按钮
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        // 页码指示器
                        Text("\(currentPage + 1) / \(imageUrls.count)")
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Spacer()
                }
            }
            #if os(iOS)
            .statusBarHidden()
            #endif
        }
    }
}

// MARK: - 可缩放图片视图

struct ZoomableImageView: View {
    let url: URL

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { value in
                                withAnimation(.spring()) {
                                    if scale < 1.0 {
                                        scale = 1.0
                                        offset = .zero
                                    } else if scale > 5.0 {
                                        scale = 5.0
                                    }
                                }
                                lastScale = scale
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if scale > 1.0 {
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                            }
                            .onEnded { value in
                                lastOffset = offset
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale > 1.0 {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }

            case .failure:
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(String(localized: "error.unknown"))
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }

            case .empty:
                ProgressView()
                    .tint(.white)

            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ImagePreviewOverlay(
        imageUrls: [
            "https://example.com/image1.jpg",
            "https://example.com/image2.jpg",
            "https://example.com/image3.jpg"
        ],
        initialIndex: 0,
        onDismiss: {}
    )
}
