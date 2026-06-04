import XCTest
@testable import HeritageOnline

/// TaxonomyViewModel 单元测试
/// 覆盖：加载成功、加载错误
@preconcurrency @MainActor
final class TaxonomyViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: TaxonomyViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = TaxonomyViewModel(repository: mockRepository)
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
        XCTAssertEqual(mockRepository.taxonomyCategoriesCallCount, 1)
        XCTAssertEqual(mockRepository.taxonomyRegionsCallCount, 1)
        XCTAssertEqual(mockRepository.taxonomyKindsCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadAllError() async {
        // Given
        mockRepository.taxonomyCategoriesResult = .failure(NetworkError.networkUnavailable)
        mockRepository.taxonomyRegionsResult = .failure(NetworkError.networkUnavailable)
        mockRepository.taxonomyKindsResult = .failure(NetworkError.networkUnavailable)

        // When
        viewModel.loadAll()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertTrue(viewModel.uiState.categories.isEmpty)
        XCTAssertTrue(viewModel.uiState.regions.isEmpty)
        XCTAssertTrue(viewModel.uiState.kinds.isEmpty)
    }
}
