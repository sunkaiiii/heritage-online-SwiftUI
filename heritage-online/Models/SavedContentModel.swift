import Foundation
import SwiftData

@Model
final class SavedContent {
    @Attribute(.unique) var contentKey: String
    var contentType: String
    var title: String?
    var summary: String?
    var coverImageUrl: String?
    var category: String?
    var region: String?
    var year: Int?
    var sourceUrl: String?

    var targetId: String?
    var targetSourceId: String?
    var targetSourceUrl: String?
    var targetCategory: String?
    var targetKind: String?

    var isFavorite: Bool = false
    var favoritedAt: Date?
    var lastViewedAt: Date?
    var createdAt: Date = Date()

    init(
        contentKey: String,
        contentType: String,
        title: String? = nil,
        summary: String? = nil,
        coverImageUrl: String? = nil,
        category: String? = nil,
        region: String? = nil,
        year: Int? = nil,
        sourceUrl: String? = nil,
        targetId: String? = nil,
        targetSourceId: String? = nil,
        targetSourceUrl: String? = nil,
        targetCategory: String? = nil,
        targetKind: String? = nil,
        isFavorite: Bool = false,
        favoritedAt: Date? = nil,
        lastViewedAt: Date? = nil
    ) {
        self.contentKey = contentKey
        self.contentType = contentType
        self.title = title
        self.summary = summary
        self.coverImageUrl = coverImageUrl
        self.category = category
        self.region = region
        self.year = year
        self.sourceUrl = sourceUrl
        self.targetId = targetId
        self.targetSourceId = targetSourceId
        self.targetSourceUrl = targetSourceUrl
        self.targetCategory = targetCategory
        self.targetKind = targetKind
        self.isFavorite = isFavorite
        self.favoritedAt = favoritedAt
        self.lastViewedAt = lastViewedAt
    }

    static func computeKey(
        id: String?,
        sourceId: String?,
        sourceUrl: String?,
        kind: String? = nil
    ) -> String {
        id ?? sourceId ?? sourceUrl ?? kind ?? UUID().uuidString
    }
}
