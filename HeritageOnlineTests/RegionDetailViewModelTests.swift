import XCTest
@testable import HeritageOnline

/// RegionDetailViewModel 单元测试
/// 覆盖：加载成功、加载错误、loading 状态
@preconcurrency @MainActor
final class RegionDetailViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: RegionDetailViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = RegionDetailViewModel(region: "beijing", repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 加载成功

    func testLoadDetailSuccess() async {
        // Given
        let detail = MockDTOFactory.regionAtlasDetailDTO()
        mockRepository.regionAtlasDetailResult = .success(detail)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.detail)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockRepository.regionAtlasDetailCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadDetailError() async {
        // Given
        mockRepository.regionAtlasDetailResult = .failure(NetworkError.notFound)

        // When
        viewModel.loadDetail()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.detail)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        viewModel.loadDetail()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }
}
