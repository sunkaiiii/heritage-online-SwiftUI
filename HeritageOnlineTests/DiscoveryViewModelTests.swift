import XCTest
@testable import HeritageOnline

/// DiscoveryViewModel 单元测试
/// 覆盖：today/trending/weekly/classic success/error、all failed、serendipity
@preconcurrency @MainActor
final class DiscoveryViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: DiscoveryViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        // Set error results BEFORE creating viewModel (init calls loadAll)
        mockRepository.discoveryTodayResult = .failure(NetworkError.networkUnavailable)
        mockRepository.discoveryTrendingResult = .failure(NetworkError.networkUnavailable)
        mockRepository.discoveryWeeklyResult = .failure(NetworkError.networkUnavailable)
        mockRepository.exploreIndexResult = .failure(NetworkError.networkUnavailable)
        mockRepository.exploreTopicsResult = .failure(NetworkError.networkUnavailable)
        mockRepository.learningPathsResult = .failure(NetworkError.networkUnavailable)
        mockRepository.featuredCollectionsResult = .failure(NetworkError.networkUnavailable)
        mockRepository.regionAtlasResult = .failure(NetworkError.networkUnavailable)
        viewModel = DiscoveryViewModel(repository: mockRepository)
        // Reset call counts after init
        mockRepository.discoveryTodayCallCount = 0
        mockRepository.discoveryTrendingCallCount = 0
        mockRepository.discoveryWeeklyCallCount = 0
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Today

    func testLoadTodaySuccess() async {
        // Given
        mockRepository.discoveryTodayResult = .success(
            DiscoveryTodayDTO(featuredDirectoryItem: nil, featuredInheritor: nil, articles: [], date: "2026-01-01")
        )

        // When
        viewModel.loadToday()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.today.data)
        XCTAssertFalse(viewModel.uiState.today.isLoading)
        XCTAssertNil(viewModel.uiState.today.error)
    }

    func testLoadTodayError() async {
        // Given - error already set in setUp

        // When
        viewModel.loadToday()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNil(viewModel.uiState.today.data)
        XCTAssertNotNil(viewModel.uiState.today.error)
    }

    // MARK: - Trending

    func testLoadTrendingSuccess() async {
        // Given
        mockRepository.discoveryTrendingResult = .success(
            DiscoveryTrendingDTO(items: [], generatedAt: nil)
        )

        // When
        viewModel.loadTrending()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.trending.data)
        XCTAssertNil(viewModel.uiState.trending.error)
    }

    func testLoadTrendingError() async {
        // Given - error already set in setUp

        // When
        viewModel.loadTrending()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.trending.error)
    }

    // MARK: - Weekly

    func testLoadWeeklySuccess() async {
        // Given
        mockRepository.discoveryWeeklyResult = .success(
            DiscoveryWeeklyDTO(weekId: "w1", sections: [], generatedAt: nil)
        )

        // When
        viewModel.loadWeekly()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.weekly.data)
        XCTAssertNil(viewModel.uiState.weekly.error)
    }

    func testLoadWeeklyError() async {
        // Given - error already set in setUp

        // When
        viewModel.loadWeekly()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.weekly.error)
    }

    // MARK: - Classic

    func testLoadClassicSuccess() async {
        // Given - all sub-requests succeed
        mockRepository.exploreIndexResult = .success(ExploreIndexDTO(regions: [], categories: [], years: []))
        mockRepository.exploreTopicsResult = .success([])
        mockRepository.learningPathsResult = .success([])
        mockRepository.featuredCollectionsResult = .success([])
        mockRepository.regionAtlasResult = .success(RegionAtlasDTO(regions: [], totals: nil, generatedAt: nil))

        // When
        viewModel.loadClassic()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.classic.data)
        XCTAssertNil(viewModel.uiState.classic.error)
    }

    func testLoadClassicAllFailedShowsError() async {
        // Given - all sub-requests already fail from setUp

        // When
        viewModel.loadClassic()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then - classic should show error
        XCTAssertNil(viewModel.uiState.classic.data)
        XCTAssertNotNil(viewModel.uiState.classic.error)
    }

    // MARK: - All Failed

    func testIsAllFailedWhenAllSectionsFail() async {
        // Given - all sections already fail from setUp

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 300_000_000)

        // Then
        XCTAssertTrue(viewModel.uiState.isAllFailed)
    }

    // MARK: - Serendipity

    func testSerendipitySuccess() async {
        // Given
        let item = DiscoveryItemDTO(id: "s1", type: "article", title: "随便看看", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com")
        mockRepository.discoverySerendipityResult = .success(item)

        // When
        viewModel.serendipity()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.serendipityItem)
        XCTAssertEqual(viewModel.uiState.serendipityItem?.id, "s1")
        XCTAssertFalse(viewModel.uiState.serendipityLoading)
    }

    func testSerendipityError() async {
        // Given
        mockRepository.discoverySerendipityResult = .failure(NetworkError.networkUnavailable)

        // When
        viewModel.serendipity()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNil(viewModel.uiState.serendipityItem)
        XCTAssertFalse(viewModel.uiState.serendipityLoading)
    }

    func testClearSerendipity() async {
        // Given
        let item = DiscoveryItemDTO(id: "s1", type: "article", title: "Test", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com")
        mockRepository.discoverySerendipityResult = .success(item)
        viewModel.serendipity()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(viewModel.uiState.serendipityItem)

        // When
        viewModel.clearSerendipity()

        // Then
        XCTAssertNil(viewModel.uiState.serendipityItem)
    }
}
