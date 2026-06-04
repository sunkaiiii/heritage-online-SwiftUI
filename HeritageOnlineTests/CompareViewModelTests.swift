import XCTest
@testable import HeritageOnline

/// CompareViewModel 单元测试
/// 覆盖：空输入校验、相同输入校验、类型切换、成功/失败
@preconcurrency @MainActor
final class CompareViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: CompareViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = CompareViewModel(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 空输入校验

    func testEmptyInputShowsError() {
        // Given - both empty
        viewModel.uiState.leftInput = ""
        viewModel.uiState.rightInput = ""

        // When
        viewModel.compare()

        // Then
        XCTAssertEqual(viewModel.uiState.errorMessage, "compare.error.empty")
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    func testLeftEmptyShowsError() {
        // Given
        viewModel.uiState.leftInput = ""
        viewModel.uiState.rightInput = "北京"

        // When
        viewModel.compare()

        // Then
        XCTAssertEqual(viewModel.uiState.errorMessage, "compare.error.empty")
    }

    func testRightEmptyShowsError() {
        // Given
        viewModel.uiState.leftInput = "北京"
        viewModel.uiState.rightInput = "  "

        // When
        viewModel.compare()

        // Then
        XCTAssertEqual(viewModel.uiState.errorMessage, "compare.error.empty")
    }

    // MARK: - 相同输入校验

    func testSameInputShowsError() {
        // Given
        viewModel.uiState.leftInput = "北京"
        viewModel.uiState.rightInput = "北京"

        // When
        viewModel.compare()

        // Then
        XCTAssertEqual(viewModel.uiState.errorMessage, "compare.error.same")
    }

    // MARK: - 类型切换

    func testUpdateTypeClearsResult() {
        // Given
        viewModel.uiState.leftInput = "北京"
        viewModel.uiState.rightInput = "上海"

        // When
        viewModel.updateType(.category)

        // Then
        XCTAssertEqual(viewModel.uiState.selectedType, .category)
        XCTAssertNil(viewModel.uiState.result)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertNil(viewModel.uiState.errorMessage)
    }

    // MARK: - 对比成功

    func testCompareRegionSuccess() async {
        // Given
        viewModel.uiState.leftInput = "北京"
        viewModel.uiState.rightInput = "上海"

        // When
        viewModel.compare()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.result)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.compareRegionsCallCount, 1)
    }

    func testCompareCategorySuccess() async {
        // Given
        viewModel.updateType(.category)
        viewModel.uiState.leftInput = "传统音乐"
        viewModel.uiState.rightInput = "传统戏剧"

        // When
        viewModel.compare()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.result)
        XCTAssertEqual(mockRepository.compareCategoriesCallCount, 1)
    }

    // MARK: - 对比失败

    func testCompareError() async {
        // Given
        mockRepository.compareResultDTO = .failure(NetworkError.networkUnavailable)
        viewModel.uiState.leftInput = "北京"
        viewModel.uiState.rightInput = "上海"

        // When
        viewModel.compare()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - Kind 校验

    func testCompareKindInvalidShowsError() async {
        // Given
        viewModel.updateType(.kind)
        viewModel.uiState.leftInput = "invalidKind"
        viewModel.uiState.rightInput = "anotherInvalid"

        // When
        viewModel.compare()
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.errorMessage, "compare.error.invalidKind")
    }

    func testCompareKindSuccess() async {
        // Given
        viewModel.updateType(.kind)
        viewModel.uiState.leftInput = "nationalProject"
        viewModel.uiState.rightInput = "culturalEcoZone"

        // When
        viewModel.compare()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.result)
        XCTAssertEqual(mockRepository.compareKindsCallCount, 1)
    }

    // MARK: - 初始参数

    func testInitialParameters() {
        // Given/When
        let vm = CompareViewModel(initialType: "category", initialLeft: "左", initialRight: "右", repository: mockRepository)

        // Then
        XCTAssertEqual(vm.uiState.selectedType, .category)
        XCTAssertEqual(vm.uiState.leftInput, "左")
        XCTAssertEqual(vm.uiState.rightInput, "右")
    }
}
