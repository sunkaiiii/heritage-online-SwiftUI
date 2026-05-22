import SwiftUI

struct FavoritesView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @Environment(SavedContentRepository.self) private var savedRepo
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    HeritagePageHeader(title: loc.localized("my_favorites"))
                        .padding(.top, 8)

                    let items = savedRepo.favorites()
                    if items.isEmpty {
                        ContentUnavailableView(
                            loc.localized("my_favorites_empty"),
                            systemImage: "heart.slash",
                            description: Text(loc.localized("my_favorites_empty_message"))
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(items) { item in
                                savedContentRow(item: item)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .background(theme.background)
            .navigationTitle(loc.localized("my_favorites"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(for: SavedContentNavigation.self) { dest in
                savedContentDetail(dest)
            }
        }
    }

    @ViewBuilder
    private func savedContentRow(item: SavedContent) -> some View {
        HeritageListCard(
            onClick: {
                guard let dest = item.navigationDestination else { return }
                navigationPath.append(dest)
            },
            image: {
                HeritageListImage(
                    imageUrl: item.coverImageUrl,
                    fallbackText: loc.localized("brand_fallback")
                )
                .frame(width: 80, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            },
            text: {
                Text(item.title ?? loc.localized("unnamed_article"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                if let summary = item.summary {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        )
    }

    @ViewBuilder
    private func savedContentDetail(_ dest: SavedContentNavigation) -> some View {
        switch dest {
        case .article(let id, let sourceId, let sourceUrl, let category):
            ArticleDetailScreen(
                articleId: id,
                sourceId: sourceId,
                sourceUrl: sourceUrl,
                category: category,
                navigationPath: $navigationPath,
                savedContentRepo: savedRepo
            )
        case .directoryItem(let id, let sourceId, let kind):
            DirectoryDetailScreen(
                itemId: id,
                sourceId: sourceId,
                kind: kind,
                navigationPath: $navigationPath,
                savedContentRepo: savedRepo
            )
        case .inheritor(let id, let sourceId):
            InheritorDetailScreen(
                inheritorId: id,
                sourceId: sourceId,
                navigationPath: $navigationPath,
                savedContentRepo: savedRepo
            )
        }
    }
}

struct RecentView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @Environment(SavedContentRepository.self) private var savedRepo
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    HeritagePageHeader(title: loc.localized("my_recent"))
                        .padding(.top, 8)

                    let items = savedRepo.recentlyViewed()
                    if items.isEmpty {
                        ContentUnavailableView(
                            loc.localized("my_recent_empty"),
                            systemImage: "clock.badge.questionmark",
                            description: Text(loc.localized("my_recent_empty_message"))
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(items) { item in
                                savedContentRow(item: item)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .background(theme.background)
            .navigationTitle(loc.localized("my_recent"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(for: SavedContentNavigation.self) { dest in
                savedContentDetail(dest)
            }
        }
    }

    @ViewBuilder
    private func savedContentRow(item: SavedContent) -> some View {
        HeritageListCard(
            onClick: {
                guard let dest = item.navigationDestination else { return }
                navigationPath.append(dest)
            },
            image: {
                HeritageListImage(
                    imageUrl: item.coverImageUrl,
                    fallbackText: loc.localized("brand_fallback")
                )
                .frame(width: 80, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            },
            text: {
                Text(item.title ?? loc.localized("unnamed_article"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                if let summary = item.summary {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        )
    }

    @ViewBuilder
    private func savedContentDetail(_ dest: SavedContentNavigation) -> some View {
        switch dest {
        case .article(let id, let sourceId, let sourceUrl, let category):
            ArticleDetailScreen(
                articleId: id,
                sourceId: sourceId,
                sourceUrl: sourceUrl,
                category: category,
                navigationPath: $navigationPath,
                savedContentRepo: savedRepo
            )
        case .directoryItem(let id, let sourceId, let kind):
            DirectoryDetailScreen(
                itemId: id,
                sourceId: sourceId,
                kind: kind,
                navigationPath: $navigationPath,
                savedContentRepo: savedRepo
            )
        case .inheritor(let id, let sourceId):
            InheritorDetailScreen(
                inheritorId: id,
                sourceId: sourceId,
                navigationPath: $navigationPath,
                savedContentRepo: savedRepo
            )
        }
    }
}

// MARK: - Navigation

enum SavedContentNavigation: Hashable {
    case article(id: String?, sourceId: String?, sourceUrl: String?, category: ArticleCategory)
    case directoryItem(id: String?, sourceId: String?, kind: DirectoryItemKind)
    case inheritor(id: String?, sourceId: String?)
}

extension SavedContent {
    var navigationDestination: SavedContentNavigation? {
        switch contentType {
        case "article":
            return .article(
                id: targetId,
                sourceId: targetSourceId,
                sourceUrl: targetSourceUrl,
                category: ArticleCategory(rawValue: targetCategory ?? "") ?? .news
            )
        case "directoryItem":
            return .directoryItem(
                id: targetId,
                sourceId: targetSourceId,
                kind: DirectoryItemKind(rawValue: targetKind ?? "") ?? .nationalProject
            )
        case "inheritor":
            return .inheritor(
                id: targetId,
                sourceId: targetSourceId
            )
        default:
            return nil
        }
    }
}
