import Foundation

struct ArticleQuery: Equatable {
    let category: ArticleCategory
    let page: Int
    let pageSize: Int
    let year: Int?
    let keywords: String?

    init(
        category: ArticleCategory = .news,
        page: Int = 1,
        pageSize: Int = 20,
        year: Int? = nil,
        keywords: String? = nil
    ) {
        self.category = category
        self.page = page
        self.pageSize = pageSize
        self.year = year
        self.keywords = keywords
    }

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "category", value: category.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
        ]
        if let year = year {
            items.append(URLQueryItem(name: "year", value: String(year)))
        }
        if let keywords = keywords, !keywords.isEmpty {
            items.append(URLQueryItem(name: "keywords", value: keywords))
        }
        return items
    }
}

struct DirectoryItemQuery: Equatable {
    let kind: DirectoryItemKind
    let page: Int
    let pageSize: Int
    let keywords: String?
    let region: String?
    let category: String?
    let year: Int?
    let listType: String?

    init(
        kind: DirectoryItemKind = .nationalProject,
        page: Int = 1,
        pageSize: Int = 20,
        keywords: String? = nil,
        region: String? = nil,
        category: String? = nil,
        year: Int? = nil,
        listType: String? = nil
    ) {
        self.kind = kind
        self.page = page
        self.pageSize = pageSize
        self.keywords = keywords
        self.region = region
        self.category = category
        self.year = year
        self.listType = listType
    }

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "kind", value: kind.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
        ]
        if let keywords = keywords, !keywords.isEmpty {
            items.append(URLQueryItem(name: "keywords", value: keywords))
        }
        if let region = region, !region.isEmpty {
            items.append(URLQueryItem(name: "region", value: region))
        }
        if let category = category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }
        if let year = year {
            items.append(URLQueryItem(name: "year", value: String(year)))
        }
        if let listType = listType, !listType.isEmpty {
            items.append(URLQueryItem(name: "listType", value: listType))
        }
        return items
    }
}

struct InheritorQuery: Equatable {
    let page: Int
    let pageSize: Int
    let keywords: String?
    let region: String?
    let category: String?
    let year: Int?
    let gender: String?

    init(
        page: Int = 1,
        pageSize: Int = 20,
        keywords: String? = nil,
        region: String? = nil,
        category: String? = nil,
        year: Int? = nil,
        gender: String? = nil
    ) {
        self.page = page
        self.pageSize = pageSize
        self.keywords = keywords
        self.region = region
        self.category = category
        self.year = year
        self.gender = gender
    }

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
        ]
        if let keywords = keywords, !keywords.isEmpty {
            items.append(URLQueryItem(name: "keywords", value: keywords))
        }
        if let region = region, !region.isEmpty {
            items.append(URLQueryItem(name: "region", value: region))
        }
        if let category = category, !category.isEmpty {
            items.append(URLQueryItem(name: "category", value: category))
        }
        if let year = year {
            items.append(URLQueryItem(name: "year", value: String(year)))
        }
        if let gender = gender, !gender.isEmpty {
            items.append(URLQueryItem(name: "gender", value: gender))
        }
        return items
    }
}
