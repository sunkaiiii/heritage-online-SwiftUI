import XCTest
@testable import HeritageOnline

/// DiscoveryDeepDiveViewModel 单元测试
/// 覆盖：seed/related 加载、错误、retry
@preconcurrency @MainActor
final class DiscoveryDeepDiveViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - 加载成功

    func testLoadSuccess() async {
        // Given
        let seed = DiscoveryItemDTO(id: "s1", type: "article", title: "Seed", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com")
        let related = [
            DiscoveryItemDTO(id: "r1", type: "directoryItem", title: "Related 1", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/r1")
        ]
        mockRepository.discoveryDeepDiveResult = .success(
            DiscoveryDeepDiveDTO(seed: seed, related: related, generatedAt: "2026-01-01")
        )

        let viewModel = DiscoveryDeepDiveViewModel(seedType: .article, seedId: "s1", repository: mockRepository)

        // When
        await viewModel.load()

        // Then
        XCTAssertNotNil(viewModel.seed)
        XCTAssertEqual(viewModel.seed?.id, "s1")
        XCTAssertEqual(viewModel.related.count, 1)
        XCTAssertEqual(viewModel.related.first?.id, "r1")
        XCTAssertEqual(viewModel.generatedAt, "2026-01-01")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    // MARK: - 加载错误

    func testLoadError() async {
        // Given
        mockRepository.discoveryDeepDiveResult = .failure(NetworkError.networkUnavailable)
        let viewModel = DiscoveryDeepDiveViewModel(seedType: .article, seedId: "s1", repository: mockRepository)

        // When
        await viewModel.load()

        // Then
        XCTAssertNil(viewModel.seed)
        XCTAssertTrue(viewModel.related.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Retry

    func testRetryReloads() async {
        // Given - first attempt fails
        mockRepository.discoveryDeepDiveResult = .failure(NetworkError.networkUnavailable)
        let viewModel = DiscoveryDeepDiveViewModel(seedType: .article, seedId: "s1", repository: mockRepository)
        await viewModel.load()
        XCTAssertNotNil(viewModel.error)

        // When - retry succeeds
        mockRepository.discoveryDeepDiveResult = .success(
            DiscoveryDeepDiveDTO(seed: nil, related: [], generatedAt: nil)
        )
        await viewModel.retry()

        // Then
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - 空结果

    func testLoadEmptyResult() async {
        // Given
        mockRepository.discoveryDeepDiveResult = .success(
            DiscoveryDeepDiveDTO(seed: nil, related: [], generatedAt: nil)
        )
        let viewModel = DiscoveryDeepDiveViewModel(seedType: .directoryItem, seedId: "d1", repository: mockRepository)

        // When
        await viewModel.load()

        // Then
        XCTAssertNil(viewModel.seed)
        XCTAssertTrue(viewModel.related.isEmpty)
        XCTAssertNil(viewModel.error)
    }
}
