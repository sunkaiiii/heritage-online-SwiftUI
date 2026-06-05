import XCTest
@testable import HeritageOnline

/// StoriesIndexViewModel 单元测试
/// 覆盖：加载成功、加载错误、空列表、loading 状态、不同入口
@preconcurrency @MainActor
final class StoriesViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: StoriesIndexViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = StoriesIndexViewModel(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 加载成功

    func testLoadAllSuccess() async {
        // Given - mock returns are already set to success defaults

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
    }

    // MARK: - 加载错误

    func testLoadAllError() async {
        // Given
        mockRepository.taxonomyRegionsResult = .failure(NetworkError.networkUnavailable)
        mockRepository.taxonomyCategoriesResult = .failure(NetworkError.networkUnavailable)
        mockRepository.timelineYearsResult = .failure(NetworkError.networkUnavailable)

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertTrue(viewModel.uiState.regions.isEmpty)
        XCTAssertTrue(viewModel.uiState.categories.isEmpty)
        XCTAssertTrue(viewModel.uiState.years.isEmpty)
    }

    // MARK: - Loading 状态

    func testLoadAllSetsLoadingTrue() async {
        // Given - 一个简单的异步期望
        viewModel.loadAll()

        // Then - loading 应被设为 true（在异步任务开始前已同步设置）
        XCTAssertTrue(viewModel.uiState.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - 空列表

    func testLoadAllEmptyResult() async {
        // Given - 使用 JSON 构造空 TaxonomyIndexDTO
        let emptyJSON = "{\"items\":[],\"generatedAt\":null}"
        let emptyTaxonomy: TaxonomyIndexDTO<TaxonomyTopicDTO> = try! JSONDecoder().decode(
            TaxonomyIndexDTO<TaxonomyTopicDTO>.self,
            from: emptyJSON.data(using: .utf8)!
        )
        mockRepository.taxonomyRegionsResult = .success(emptyTaxonomy)
        mockRepository.taxonomyCategoriesResult = .success(emptyTaxonomy)
        mockRepository.timelineYearsResult = .success([])

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertTrue(viewModel.uiState.regions.isEmpty)
        XCTAssertTrue(viewModel.uiState.categories.isEmpty)
        XCTAssertTrue(viewModel.uiState.years.isEmpty)
    }

    // MARK: - 地区入口有数据

    func testLoadAllWithRegions() async {
        // Given - 用 JSON 构造有数据的 region
        let json = """
        {"items":[{"type":"region","key":"beijing","title":"北京","subtitle":null,"directoryItemCount":10,"inheritorCount":5,"articleCount":3,"total":18,"topRegions":[],"topCategories":[],"coverImage":null}],"generatedAt":null}
        """
        let taxonomy: TaxonomyIndexDTO<TaxonomyTopicDTO> = try! JSONDecoder().decode(
            TaxonomyIndexDTO<TaxonomyTopicDTO>.self,
            from: json.data(using: .utf8)!
        )

        mockRepository.taxonomyRegionsResult = .success(taxonomy)

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.regions.count, 1)
        XCTAssertEqual(viewModel.uiState.regions.first?.key, "beijing")
    }

    // MARK: - 年份入口有数据

    func testLoadAllWithYears() async {
        // Given - 使用 public init 构造 TimelineYearBucketDTO
        let yearBucket = TimelineYearBucketDTO(year: 2024, total: 10, articleCount: 5, directoryItemCount: 3, inheritorCount: 2)
        mockRepository.timelineYearsResult = .success([yearBucket])

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.years.count, 1)
        XCTAssertEqual(viewModel.uiState.years.first?.year, 2024)
    }

    // MARK: - Retry 重新加载清除错误

    func testRetryClearsErrorAndReloads() async {
        // Given - 首次加载失败
        mockRepository.taxonomyRegionsResult = .failure(NetworkError.networkUnavailable)
        mockRepository.taxonomyCategoriesResult = .failure(NetworkError.networkUnavailable)
        mockRepository.timelineYearsResult = .failure(NetworkError.networkUnavailable)
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNotNil(viewModel.uiState.error)

        // When - retry（使用 JSON 构造成功的 mock 数据）
        let emptyJSON = "{\"items\":[],\"generatedAt\":null}"
        let emptyTaxonomy: TaxonomyIndexDTO<TaxonomyTopicDTO> = try! JSONDecoder().decode(
            TaxonomyIndexDTO<TaxonomyTopicDTO>.self,
            from: emptyJSON.data(using: .utf8)!
        )
        mockRepository.taxonomyRegionsResult = .success(emptyTaxonomy)
        mockRepository.taxonomyCategoriesResult = .success(emptyTaxonomy)
        mockRepository.timelineYearsResult = .success([])
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then - 错误被清除
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }
}
