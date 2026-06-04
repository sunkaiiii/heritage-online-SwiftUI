import Foundation

/// 对比页面状态
@MainActor
@Observable
final class CompareUiState {
    var selectedType: CompareType = .region
    var leftInput: String = ""
    var rightInput: String = ""
    var isLoading = false
    var result: CompareResultDTO?
    var error: AppError?
    var errorMessage: String?
}

/// 对比页面 ViewModel
@MainActor
@Observable
final class CompareViewModel {
    let uiState = CompareUiState()
    private let repository: HeritageRepository

    init(initialType: String? = nil, initialLeft: String? = nil, initialRight: String? = nil, repository: HeritageRepository = DefaultHeritageRepository()) {
        self.repository = repository
        if let initialType, let type = CompareType(rawValue: initialType) {
            uiState.selectedType = type
        }
        if let initialLeft {
            uiState.leftInput = initialLeft
        }
        if let initialRight {
            uiState.rightInput = initialRight
        }
    }

    func updateType(_ type: CompareType) {
        uiState.selectedType = type
        uiState.result = nil
        uiState.error = nil
        uiState.errorMessage = nil
    }

    func compare() {
        // 校验
        let left = uiState.leftInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let right = uiState.rightInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !left.isEmpty, !right.isEmpty else {
            uiState.errorMessage = "compare.error.empty"
            return
        }

        guard left != right else {
            uiState.errorMessage = "compare.error.same"
            return
        }

        uiState.isLoading = true
        uiState.error = nil
        uiState.errorMessage = nil
        uiState.result = nil

        Task {
            do {
                let result: CompareResultDTO
                switch uiState.selectedType {
                case .region:
                    result = try await repository.compareRegions(left: left, right: right, limit: 6)
                case .category:
                    result = try await repository.compareCategories(left: left, right: right, limit: 6)
                case .kind:
                    guard let leftKind = DirectoryItemKind(rawValue: left),
                          let rightKind = DirectoryItemKind(rawValue: right) else {
                        uiState.errorMessage = "compare.error.invalidKind"
                        uiState.isLoading = false
                        return
                    }
                    result = try await repository.compareKinds(left: leftKind, right: rightKind, limit: 6)
                }
                uiState.result = result
                uiState.isLoading = false
            } catch {
                uiState.error = AppError.from(error)
                uiState.isLoading = false
            }
        }
    }
}
