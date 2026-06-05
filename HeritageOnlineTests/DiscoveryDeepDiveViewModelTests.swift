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

    // MARK: - stableListID 稳定性测试

    /// 不同 item 应产生不同的 stableListID
    func testStableListIDDifferentForDifferentItems() {
        let item1 = DiscoveryItemDTO(id: "a1", type: "article", title: "文章1", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/a1")
        let item2 = DiscoveryItemDTO(id: "a2", type: "article", title: "文章2", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/a2")

        XCTAssertNotEqual(item1.stableListID, item2.stableListID)
    }

    /// 同 sourceUrl 但不同 id 应产生不同的 stableListID
    func testStableListIDDifferentWhenSameSourceUrlDifferentId() {
        let item1 = DiscoveryItemDTO(id: "a1", type: "article", title: "文章1", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/same")
        let item2 = DiscoveryItemDTO(id: "a2", type: "article", title: "文章2", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/same")

        XCTAssertNotEqual(item1.stableListID, item2.stableListID)
    }

    /// id 为 nil 时，不同 title 应产生不同的 stableListID
    func testStableListIDDifferentWhenIdNil() {
        let item1 = DiscoveryItemDTO(id: nil, type: "article", title: "标题A", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/x")
        let item2 = DiscoveryItemDTO(id: nil, type: "article", title: "标题B", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/x")

        XCTAssertNotEqual(item1.stableListID, item2.stableListID)
    }

    /// 不同 type 应产生不同的 stableListID（即使其他字段相同）
    func testStableListIDDifferentForDifferentTypes() {
        let article = DiscoveryItemDTO(id: "x1", type: "article", title: "标题", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/x1")
        let directory = DiscoveryItemDTO(id: "x1", type: "directoryItem", title: "标题", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/x1")

        XCTAssertNotEqual(article.stableListID, directory.stableListID)
    }

    /// stableListID 是确定性的（相同输入 → 相同输出）
    func testStableListIDIsDeterministic() {
        let item = DiscoveryItemDTO(id: "d1", type: "article", title: "确定性测试", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com/d1")

        XCTAssertEqual(item.stableListID, item.stableListID)
    }
}
