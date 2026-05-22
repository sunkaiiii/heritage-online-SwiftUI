import SwiftUI
import Observation

@MainActor
@Observable
class HeritageImageLoader {
    var phase: AsyncImagePhase = .empty

    private var task: Task<Void, Never>?
    private var currentURL: URL?

    func load(url: URL?) {
        guard url != currentURL else { return }
        task?.cancel()
        currentURL = url

        guard let url = url else {
            phase = .empty
            return
        }
        phase = .empty
        task = Task {
            do {
                let (data, response) = try await heritageTrustedSession.data(from: url)
                guard !Task.isCancelled else { return }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    phase = .failure(URLError(.badServerResponse))
                    return
                }
                #if canImport(UIKit)
                if let uiImage = UIImage(data: data) {
                    phase = .success(Image(uiImage: uiImage))
                } else {
                    phase = .failure(URLError(.cannotDecodeContentData))
                }
                #elseif canImport(AppKit)
                if let nsImage = NSImage(data: data) {
                    phase = .success(Image(nsImage: nsImage))
                } else {
                    phase = .failure(URLError(.cannotDecodeContentData))
                }
                #endif
            } catch {
                guard !Task.isCancelled else { return }
                phase = .failure(error)
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        currentURL = nil
    }
}

struct HeritageAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var loader = HeritageImageLoader()

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            switch loader.phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
            case .failure:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
        .onAppear {
            loader.load(url: url)
        }
        .onDisappear {
            loader.cancel()
        }
        .onChange(of: url) { _, newUrl in
            loader.load(url: newUrl)
        }
    }
}
