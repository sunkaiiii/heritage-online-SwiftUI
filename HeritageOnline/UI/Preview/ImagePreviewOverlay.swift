import SwiftUI

/// 图片预览覆盖层
/// 对齐 Android ImagePreviewOverlay
/// 支持多图、关闭、缩放、页码显示
struct ImagePreviewOverlay: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 有效的图片 URL 列表（已过滤非法 URL）
    let validUrls: [String]

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
        // 过滤有效的 URL 字符串
        let filtered = imageUrls.filter { urlString in
            guard let url = URL(string: urlString) else { return false }
            return url.scheme == "http" || url.scheme == "https"
        }
        self.validUrls = filtered
        self.onDismiss = onDismiss

        // 对 initialIndex 做 clamp
        let safeIndex = filtered.isEmpty ? 0 : min(max(initialIndex, 0), filtered.count - 1)
        self._currentPage = State(initialValue: safeIndex)
    }

    var body: some View {
        if validUrls.isEmpty {
            EmptyView()
        } else {
            ZStack {
                // 背景
                Color.black.opacity(0.96)
                    .ignoresSafeArea()

                // 图片内容
                TabView(selection: $currentPage) {
                    ForEach(Array(validUrls.enumerated()), id: \.offset) { index, urlString in
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

                        // 页码指示器（使用过滤后的 URL 数量）
                        Text("\(currentPage + 1) / \(validUrls.count)")
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

    @State private var loadedImage: Image?
    @State private var isLoading = true
    @State private var loadFailed = false

    var body: some View {
        Group {
            if let image = loadedImage {
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

            } else if isLoading {
                ProgressView()
                    .tint(.white)
            } else if loadFailed {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("error.unknown")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .task {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
            do {
                let session = HeritageHTTPClient.shared.session
                let (data, _) = try await session.data(for: request)
                #if os(macOS)
                if let nsImage = NSImage(data: data) {
                    loadedImage = Image(nsImage: nsImage)
                } else {
                    loadFailed = true
                }
                #else
                if let uiImage = UIImage(data: data) {
                    loadedImage = Image(uiImage: uiImage)
                } else {
                    loadFailed = true
                }
                #endif
            } catch {
                loadFailed = true
            }
            isLoading = false
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
