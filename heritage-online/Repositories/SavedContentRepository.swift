import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class SavedContentRepository {
    private let modelContext: ModelContext
    private let maxRecent = 100

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func find(contentKey: String) -> SavedContent? {
        var descriptor = FetchDescriptor<SavedContent>(
            predicate: #Predicate { $0.contentKey == contentKey }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    func isFavorite(contentKey: String) -> Bool {
        find(contentKey: contentKey)?.isFavorite == true
    }

    func toggleFavorite(
        contentKey: String,
        contentType: String,
        title: String?,
        summary: String?,
        coverImageUrl: String?,
        category: String?,
        region: String?,
        year: Int?,
        sourceUrl: String?,
        targetId: String?,
        targetSourceId: String?,
        targetSourceUrl: String?,
        targetCategory: String?,
        targetKind: String?
    ) {
        if let existing = find(contentKey: contentKey) {
            existing.isFavorite.toggle()
            existing.favoritedAt = existing.isFavorite ? Date() : nil
        } else {
            let content = SavedContent(
                contentKey: contentKey,
                contentType: contentType,
                title: title,
                summary: summary,
                coverImageUrl: coverImageUrl,
                category: category,
                region: region,
                year: year,
                sourceUrl: sourceUrl,
                targetId: targetId,
                targetSourceId: targetSourceId,
                targetSourceUrl: targetSourceUrl,
                targetCategory: targetCategory,
                targetKind: targetKind,
                isFavorite: true,
                favoritedAt: Date(),
                lastViewedAt: Date()
            )
            modelContext.insert(content)
        }
        try? modelContext.save()
    }

    func recordViewed(
        contentKey: String,
        contentType: String,
        title: String?,
        summary: String?,
        coverImageUrl: String?,
        category: String?,
        region: String?,
        year: Int?,
        sourceUrl: String?,
        targetId: String?,
        targetSourceId: String?,
        targetSourceUrl: String?,
        targetCategory: String?,
        targetKind: String?
    ) {
        if let existing = find(contentKey: contentKey) {
            existing.lastViewedAt = Date()
        } else {
            let content = SavedContent(
                contentKey: contentKey,
                contentType: contentType,
                title: title,
                summary: summary,
                coverImageUrl: coverImageUrl,
                category: category,
                region: region,
                year: year,
                sourceUrl: sourceUrl,
                targetId: targetId,
                targetSourceId: targetSourceId,
                targetSourceUrl: targetSourceUrl,
                targetCategory: targetCategory,
                targetKind: targetKind,
                isFavorite: false,
                lastViewedAt: Date()
            )
            modelContext.insert(content)
        }
        try? modelContext.save()
        trimRecent()
    }

    func favorites() -> [SavedContent] {
        var descriptor = FetchDescriptor<SavedContent>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.favoritedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func recentlyViewed() -> [SavedContent] {
        var descriptor = FetchDescriptor<SavedContent>(
            predicate: #Predicate { $0.lastViewedAt != nil },
            sortBy: [SortDescriptor(\.lastViewedAt, order: .reverse)]
        )
        descriptor.fetchLimit = maxRecent
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func removeFavorite(contentKey: String) {
        if let existing = find(contentKey: contentKey) {
            existing.isFavorite = false
            existing.favoritedAt = nil
            try? modelContext.save()
        }
    }

    private func trimRecent() {
        let allRecent = recentlyViewed()
        guard allRecent.count > maxRecent else { return }
        let toDelete = allRecent[maxRecent...]
        for item in toDelete where !item.isFavorite {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}
