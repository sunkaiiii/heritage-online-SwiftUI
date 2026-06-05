import XCTest
@testable import HeritageOnline

/// TaxonomyDetailViewModel 单元测试
/// 覆盖：按 category 加载、按 region 加载、未知类型、加载错误、loading 状态
@preconcurrency @MainActor
final class TaxonomyDetailViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - 按 category 加载成功

    func testLoadCategoryDetailSuccess() async {
        // Given
        let detail = MockDTOFactory.taxonomyCategoryDetailDTO()
        mockRepository.taxonomyCategoryDetailResult = .success(detail)
        let viewModel = TaxonomyDetailViewModel(type: "category", key: "传统技艺", repository: mockRepository)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.categoryDetail)
        XCTAssertNil(viewModel.uiState.regionDetail)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.taxonomyCategoryDetailCallCount, 1)
    }

    // MARK: - 按 region 加载成功

    func testLoadRegionDetailSuccess() async {
        // Given
        let detail = MockDTOFactory.taxonomyRegionDetailDTO()
        mockRepository.taxonomyRegionDetailResult = .success(detail)
        let viewModel = TaxonomyDetailViewModel(type: "region", key: "北京", repository: mockRepository)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.uiState.categoryDetail)
        XCTAssertNotNil(viewModel.uiState.regionDetail)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.taxonomyRegionDetailCallCount, 1)
    }

    // MARK: - 未知类型

    func testLoadUnknownTypeReturnsError() async {
        // Given
        let viewModel = TaxonomyDetailViewModel(type: "unknown", key: "test", repository: mockRepository)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.uiState.categoryDetail)
        XCTAssertNil(viewModel.uiState.regionDetail)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - 加载错误

    func testLoadDetailError() async {
        // Given
        mockRepository.taxonomyCategoryDetailResult = .failure(NetworkError.notFound)
        let viewModel = TaxonomyDetailViewModel(type: "category", key: "test", repository: mockRepository)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.uiState.categoryDetail)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        let viewModel = TaxonomyDetailViewModel(type: "category", key: "test", repository: mockRepository)
        viewModel.loadDetail()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.uiState.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - 标题和类型

    func testTitleAndType() async {
        // Given
        let detail = MockDTOFactory.taxonomyCategoryDetailDTO()
        mockRepository.taxonomyCategoryDetailResult = .success(detail)
        let viewModel = TaxonomyDetailViewModel(type: "category", key: "传统技艺", repository: mockRepository)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertEqual(viewModel.topicType, "category")
        XCTAssertEqual(viewModel.topicKey, "传统技艺")
    }
}
