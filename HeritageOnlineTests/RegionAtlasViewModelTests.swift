import XCTest
@testable import HeritageOnline

/// RegionAtlasViewModel 单元测试
/// 覆盖：加载成功、加载错误、loading 状态
@preconcurrency @MainActor
final class RegionAtlasViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: RegionAtlasViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = RegionAtlasViewModel(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 加载成功

    func testLoadAtlasSuccess() async {
        // Given
        let atlas = MockDTOFactory.regionAtlasDTO()
        mockRepository.regionAtlasResult = .success(atlas)

        // When
        viewModel.loadAtlas()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNotNil(viewModel.atlas)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(mockRepository.regionAtlasCallCount, 1)
    }

    // MARK: - 加载错误

    func testLoadAtlasError() async {
        // Given
        mockRepository.regionAtlasResult = .failure(NetworkError.networkUnavailable)

        // When
        viewModel.loadAtlas()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertNil(viewModel.atlas)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Loading 状态

    func testLoadingState() async {
        // Given
        viewModel.loadAtlas()

        // Then - loading 应被设为 true
        XCTAssertTrue(viewModel.isLoading)

        // 等待加载完成
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(viewModel.isLoading)
    }
}
