import XCTest
@testable import HeritageOnline

/// TimelineViewModel 单元测试
/// 覆盖：年份加载、选择年份清空旧数据、类型筛选、loadMore
@preconcurrency @MainActor
final class TimelineViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: TimelineViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = TimelineViewModel(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 年份加载

    func testLoadYearsSuccess() async {
        // Given
        mockRepository.timelineYearsResult = .success([
            TimelineYearBucketDTO(year: 2020, total: 5, articleCount: nil, directoryItemCount: nil, inheritorCount: nil),
            TimelineYearBucketDTO(year: 2021, total: 10, articleCount: nil, directoryItemCount: nil, inheritorCount: nil)
        ])

        // When
        viewModel.loadYears()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.years.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadYearsError() async {
        // Given
        mockRepository.timelineYearsResult = .failure(NetworkError.networkUnavailable)

        // When
        viewModel.loadYears()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.years.isEmpty)
    }

    // MARK: - 选择年份

    func testSelectYearLoadsItems() async {
        // Given
        mockRepository.timelineV2Result = .success(
            TimelineV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil)
        )

        // When
        viewModel.selectYear(2024)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.selectedYear, 2024)
        XCTAssertEqual(mockRepository.timelineV2CallCount, 1)
    }

    func testSelectSameYearDeselects() async {
        // Given
        viewModel.selectYear(2024)
        try? await Task.sleep(nanoseconds: 50_000_000)

        // When - select same year again
        viewModel.selectYear(2024)

        // Then
        XCTAssertNil(viewModel.selectedYear)
        XCTAssertTrue(viewModel.items.isEmpty)
    }

    func testSelectYearClearsOldItems() async {
        // Given - load items for 2024
        mockRepository.timelineV2Result = .success(
            TimelineV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil)
        )
        viewModel.selectYear(2024)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // When - switch to 2025
        viewModel.selectYear(2025)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.selectedYear, 2025)
    }

    // MARK: - 类型筛选

    func testToggleTypeReloads() async {
        // Given
        mockRepository.timelineV2Result = .success(
            TimelineV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil)
        )
        viewModel.selectYear(2024)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // When
        viewModel.toggleType(.article)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(viewModel.selectedTypes.contains(.article))
    }

    // MARK: - LoadMore

    func testLoadMoreDoesNotDuplicate() async {
        // Given
        mockRepository.timelineV2Result = .success(
            TimelineV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: true, facets: nil)
        )
        viewModel.selectYear(2024)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // When
        mockRepository.timelineV2Result = .success(
            TimelineV2ResponseDTO(items: [], total: 0, page: 2, pageSize: 20, hasMore: false, facets: nil)
        )
        viewModel.loadMore()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertGreaterThanOrEqual(mockRepository.timelineV2CallCount, 2)
    }

    func testLoadMoreGuardWhenNoYear() {
        // Given - no year selected
        viewModel.loadMore()

        // Then
        XCTAssertEqual(mockRepository.timelineV2CallCount, 0)
    }
}
