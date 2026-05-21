import SwiftUI

struct ImagePreviewView: View {
    let imageUrls: [String]
    let initialIndex: Int
    let onDismiss: () -> Void

    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    init(imageUrls: [String], initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.imageUrls = imageUrls
        self.initialIndex = initialIndex
        self.onDismiss = onDismiss
        self._currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.96)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            if !imageUrls.isEmpty, let url = URL(string: imageUrls[currentIndex]) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                SimultaneousGesture(
                                    magnificationGesture,
                                    dragGesture
                                )
                            )
                            .onTapGesture {
                                onDismiss()
                            }
                    case .failure:
                        errorView
                    case .empty:
                        ProgressView()
                            .tint(.white)
                    @unknown default:
                        errorView
                    }
                }
            }

            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                    }

                    Text("\(currentIndex + 1) / \(imageUrls.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 60)

                Spacer()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 && currentIndex > 0 {
                        withAnimation { currentIndex -= 1 }
                    } else if value.translation.width < -100 && currentIndex < imageUrls.count - 1 {
                        withAnimation { currentIndex += 1 }
                    }
                }
        )
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1.0
                withAnimation {
                    if scale < 1 {
                        scale = 1
                    }
                    offset = .zero
                    lastOffset = .zero
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.white)
            Text(String(localized: "content_load_failed"))
                .foregroundColor(.white)
        }
    }
}
