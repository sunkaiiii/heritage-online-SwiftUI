import XCTest
@testable import HeritageOnline

/// ExploreTopicViewModel 单元测试
/// 覆盖：加载成功、加载错误、loading 状态
@preconcurrency @MainActor
final class ExploreTopicViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: ExploreTopicViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = ExploreTopicViewModel(type: "region", key: "beijing", repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 加载成功

    func testLoadTopicSuccess() async {
        // Given
        let topic = MockDTOFactory.exploreTopicV2DTO()
        mockRepository.exploreTopicResult = .success(topic)

        // When
        viewModel.loadTopic()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.topic)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockRepository.exploreTopicCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadTopicError() async {
        // Given
        mockRepository.exploreTopicResult = .failure(NetworkError.notFound)

        // When
        viewModel.loadTopic()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.topic)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        viewModel.loadTopic()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }
}
