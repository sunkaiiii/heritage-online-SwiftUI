import Foundation

/// 故事详情页面状态
@MainActor
@Observable
final class StoryDetailUiState {
    var isLoading = true
    var error: AppError?
    var story: DataStoryDTO?
}

/// 故事详情 ViewModel
@MainActor
@Observable
final class StoryDetailViewModel {
    let uiState = StoryDetailUiState()
    private let region: String?
    private let category: String?
    private let year: Int?
    private let repository: HeritageRepository

    init(region: String? = nil, category: String? = nil, year: Int? = nil, repository: HeritageRepository = DefaultHeritageRepository()) {
        self.region = region
        self.category = category
        self.year = year
        self.repository = repository
    }

    func loadStory() {
        uiState.isLoading = true
        uiState.error = nil

        Task {
            do {
                let story: DataStoryDTO
                if let region {
                    story = try await repository.regionStory(region: region)
                } else if let category {
                    story = try await repository.categoryStory(category: category)
                } else if let year {
                    story = try await repository.yearStory(year: year)
                } else {
                    throw AppError.unknown("Missing story identifier")
                }
                uiState.story = story
                uiState.isLoading = false
            } catch {
                uiState.error = AppError.from(error)
                uiState.isLoading = false
            }
        }
    }
}
