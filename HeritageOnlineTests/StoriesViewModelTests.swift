import XCTest
@testable import HeritageOnline

/// StoriesIndexViewModel 单元测试
/// 覆盖：加载成功、加载错误
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
}
