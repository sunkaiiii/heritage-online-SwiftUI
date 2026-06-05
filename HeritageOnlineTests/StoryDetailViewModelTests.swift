import XCTest
@testable import HeritageOnline

/// StoryDetailViewModel 单元测试
/// 覆盖：按 region/category/year 加载、加载错误、loading 状态
@preconcurrency @MainActor
final class StoryDetailViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - 按 region 加载成功

    func testLoadStoryByRegionSuccess() async {
        // Given
        let story = MockDTOFactory.dataStoryDTO()
        mockRepository.regionStoryResult = .success(story)
        let viewModel = StoryDetailViewModel(region: "beijing", repository: mockRepository)

        // When
        viewModel.loadStory()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.story)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.regionStoryCallCount, 1)
    }

    // MARK: - 按 category 加载成功

    func testLoadStoryByCategorySuccess() async {
        // Given
        let story = MockDTOFactory.dataStoryDTO()
        mockRepository.categoryStoryResult = .success(story)
        let viewModel = StoryDetailViewModel(category: "传统技艺", repository: mockRepository)

        // When
        viewModel.loadStory()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.story)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.categoryStoryCallCount, 1)
    }

    // MARK: - 按 year 加载成功

    func testLoadStoryByYearSuccess() async {
        // Given
        let story = MockDTOFactory.dataStoryDTO()
        mockRepository.yearStoryResult = .success(story)
        let viewModel = StoryDetailViewModel(year: 2024, repository: mockRepository)

        // When
        viewModel.loadStory()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.story)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.yearStoryCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadStoryError() async {
        // Given
        mockRepository.regionStoryResult = .failure(NetworkError.notFound)
        let viewModel = StoryDetailViewModel(region: "test", repository: mockRepository)

        // When
        viewModel.loadStory()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.uiState.story)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        let viewModel = StoryDetailViewModel(region: "beijing", repository: mockRepository)
        viewModel.loadStory()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.uiState.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.uiState.isLoading)
    }
}
