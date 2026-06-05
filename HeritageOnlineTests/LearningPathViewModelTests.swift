import XCTest
@testable import HeritageOnline

/// LearningPathViewModel 单元测试
/// 覆盖：加载成功、加载错误、loading 状态
@preconcurrency @MainActor
final class LearningPathViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: LearningPathViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = LearningPathViewModel(id: "path-1", repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 加载成功

    func testLoadPathSuccess() async {
        // Given
        let path = MockDTOFactory.learningPathDetailDTO()
        mockRepository.learningPathDetailResult = .success(path)

        // When
        viewModel.loadPath()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.path)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockRepository.learningPathDetailCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadPathError() async {
        // Given
        mockRepository.learningPathDetailResult = .failure(NetworkError.notFound)

        // When
        viewModel.loadPath()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.path)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        viewModel.loadPath()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }
}
