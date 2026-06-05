import XCTest
@testable import HeritageOnline

/// CollectionDetailViewModel 单元测试
/// 覆盖：按 id 加载、按 type+key 加载、加载错误、loading 状态
@preconcurrency @MainActor
final class CollectionDetailViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - 按 id 加载成功

    func testLoadCollectionByIdSuccess() async {
        // Given
        let collection = MockDTOFactory.collectionDTO()
        mockRepository.collectionResult = .success(collection)
        let viewModel = CollectionDetailViewModel(id: "latest-news", repository: mockRepository)

        // When
        viewModel.loadCollection()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.collection)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockRepository.collectionCallCount, 1)
        XCTAssertEqual(mockRepository.topicCollectionCallCount, 0)
    }

    // MARK: - 按 type+key 加载成功

    func testLoadCollectionByTypeAndKeySuccess() async {
        // Given
        let collection = MockDTOFactory.collectionDTO()
        mockRepository.collectionResult = .success(collection)
        let viewModel = CollectionDetailViewModel(type: "region", key: "beijing", repository: mockRepository)

        // When
        viewModel.loadCollection()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.collection)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockRepository.topicCollectionCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadCollectionError() async {
        // Given
        mockRepository.collectionResult = .failure(NetworkError.notFound)
        let viewModel = CollectionDetailViewModel(id: "test", repository: mockRepository)

        // When
        viewModel.loadCollection()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.collection)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        let viewModel = CollectionDetailViewModel(id: "test", repository: mockRepository)
        viewModel.loadCollection()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }
}
