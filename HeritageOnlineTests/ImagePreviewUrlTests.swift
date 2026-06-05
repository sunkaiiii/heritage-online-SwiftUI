import XCTest
@testable import HeritageOnline

/// 图片 URL 选择测试
/// 对齐 Android ImagePreviewUrlsTest
final class ImagePreviewUrlTests: XCTestCase {

    // MARK: - listUrl 优先级测试

    func testListUrlReturnsDisplayUrlFirst() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: "https://example.com/original.jpg",
            displayUrl: "https://example.com/display.jpg",
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.listUrl(from: asset), "https://example.com/display.jpg")
    }

    func testListUrlFallsBackToThumbnailUrl() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: "https://example.com/original.jpg",
            displayUrl: nil,
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.listUrl(from: asset), "https://example.com/thumb.jpg")
    }

    func testListUrlFallsBackToOriginalUrl() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: "https://example.com/original.jpg",
            displayUrl: nil,
            thumbnailUrl: nil,
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.listUrl(from: asset), "https://example.com/original.jpg")
    }

    func testListUrlFallsBackToSourceUrl() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: nil,
            displayUrl: nil,
            thumbnailUrl: nil,
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.listUrl(from: asset), "https://example.com/source.jpg")
    }

    func testListUrlReturnsNilWhenAllFieldsAreNil() {
        let asset = MediaAssetDTO(
            sourceUrl: nil,
            originalUrl: nil,
            displayUrl: nil,
            thumbnailUrl: nil,
            altText: nil
        )
        XCTAssertNil(ImagePreviewUrl.listUrl(from: asset))
    }

    func testListUrlReturnsNilForNilAsset() {
        XCTAssertNil(ImagePreviewUrl.listUrl(from: nil))
    }

    // MARK: - previewUrl 优先级测试

    func testPreviewUrlReturnsOriginalUrlFirst() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: "https://example.com/original.jpg",
            displayUrl: "https://example.com/display.jpg",
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.previewUrl(from: asset), "https://example.com/original.jpg")
    }

    func testPreviewUrlFallsBackToDisplayUrl() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: nil,
            displayUrl: "https://example.com/display.jpg",
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.previewUrl(from: asset), "https://example.com/display.jpg")
    }

    func testPreviewUrlFallsBackToSourceUrl() {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: nil,
            displayUrl: nil,
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.previewUrl(from: asset), "https://example.com/source.jpg")
    }

    func testPreviewUrlFallsBackToThumbnailUrl() {
        let asset = MediaAssetDTO(
            sourceUrl: nil,
            originalUrl: nil,
            displayUrl: nil,
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )
        XCTAssertEqual(ImagePreviewUrl.previewUrl(from: asset), "https://example.com/thumb.jpg")
    }

    // MARK: - collect 测试

    func testCollectReturnsEmptyWhenAllInputsAreEmpty() {
        let urls = ImagePreviewUrl.collect(coverImage: nil, gallery: [], contentBlocks: [])
        XCTAssertTrue(urls.isEmpty)
    }

    func testCollectIncludesCoverImageFirst() {
        let cover = MediaAssetDTO(
            sourceUrl: nil,
            originalUrl: nil,
            displayUrl: "https://example.com/cover.jpg",
            thumbnailUrl: nil,
            altText: nil
        )
        let urls = ImagePreviewUrl.collect(coverImage: cover, gallery: [], contentBlocks: [])
        XCTAssertEqual(urls, ["https://example.com/cover.jpg"])
    }

    func testCollectOrdersCoverThenGalleryThenContentBlocks() {
        let cover = MediaAssetDTO(
            sourceUrl: nil,
            originalUrl: nil,
            displayUrl: "https://example.com/cover.jpg",
            thumbnailUrl: nil,
            altText: nil
        )
        let gallery = [
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/gallery1.jpg", thumbnailUrl: nil, altText: nil),
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/gallery2.jpg", thumbnailUrl: nil, altText: nil),
        ]
        let contentBlocks = [
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/body1.jpg", thumbnailUrl: nil, altText: nil)),
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/body2.jpg", thumbnailUrl: nil, altText: nil)),
        ]
        let urls = ImagePreviewUrl.collect(coverImage: cover, gallery: gallery, contentBlocks: contentBlocks)
        XCTAssertEqual(urls, [
            "https://example.com/cover.jpg",
            "https://example.com/gallery1.jpg",
            "https://example.com/gallery2.jpg",
            "https://example.com/body1.jpg",
            "https://example.com/body2.jpg",
        ])
    }

    func testCollectFiltersOutImagesWithNoPreviewableUrl() {
        let cover = MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil)
        let gallery = [
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/gallery1.jpg", thumbnailUrl: nil, altText: nil),
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil),
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/gallery3.jpg", thumbnailUrl: nil, altText: nil),
        ]
        let contentBlocks = [
            ArticleContentBlockDTO(type: .text, text: "Some text", image: nil),
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil)),
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/body1.jpg", thumbnailUrl: nil, altText: nil)),
        ]
        let urls = ImagePreviewUrl.collect(coverImage: cover, gallery: gallery, contentBlocks: contentBlocks)
        XCTAssertEqual(urls, [
            "https://example.com/gallery1.jpg",
            "https://example.com/gallery3.jpg",
            "https://example.com/body1.jpg",
        ])
    }

    func testCollectSkipsNonImageContentBlocks() {
        let contentBlocks = [
            ArticleContentBlockDTO(type: .heading, text: "Heading", image: nil),
            ArticleContentBlockDTO(type: .text, text: "Body text", image: nil),
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/img.jpg", thumbnailUrl: nil, altText: nil)),
        ]
        let urls = ImagePreviewUrl.collect(coverImage: nil, gallery: [], contentBlocks: contentBlocks)
        XCTAssertEqual(urls, ["https://example.com/img.jpg"])
    }

    // MARK: - Smoke 测试

    func testSmokeArticleDetailPreviewUrls() {
        let cover = MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/article-cover.jpg", thumbnailUrl: nil, altText: nil)
        let contentBlocks = [
            ArticleContentBlockDTO(type: .text, text: "Intro paragraph", image: nil),
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/article-img1.jpg", thumbnailUrl: nil, altText: nil)),
            ArticleContentBlockDTO(type: .heading, text: "Section 2", image: nil),
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/article-img2.jpg", thumbnailUrl: nil, altText: nil)),
        ]
        let urls = ImagePreviewUrl.collect(coverImage: cover, gallery: [], contentBlocks: contentBlocks)
        XCTAssertEqual(urls.count, 3)
        XCTAssertEqual(urls[0], "https://example.com/article-cover.jpg")
        XCTAssertEqual(urls[1], "https://example.com/article-img1.jpg")
        XCTAssertEqual(urls[2], "https://example.com/article-img2.jpg")
    }

    func testSmokeDirectoryDetailPreviewUrlsWithGallery() {
        let cover = MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/dir-cover.jpg", thumbnailUrl: nil, altText: nil)
        let gallery = [
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: "https://example.com/dir-g1.jpg", altText: nil),
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: "https://example.com/dir-g2.jpg", altText: nil),
            MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: "https://example.com/dir-g3.jpg", altText: nil),
        ]
        let contentBlocks = [
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: "https://example.com/dir-body.jpg", originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil)),
        ]
        let urls = ImagePreviewUrl.collect(coverImage: cover, gallery: gallery, contentBlocks: contentBlocks)
        XCTAssertEqual(urls.count, 5)
        XCTAssertEqual(urls[0], "https://example.com/dir-cover.jpg")
        XCTAssertEqual(urls[1], "https://example.com/dir-g1.jpg")
        XCTAssertEqual(urls[2], "https://example.com/dir-g2.jpg")
        XCTAssertEqual(urls[3], "https://example.com/dir-g3.jpg")
        XCTAssertEqual(urls[4], "https://example.com/dir-body.jpg")
    }

    func testSmokeNoPreviewWhenAllImagesHaveNullUrls() {
        let cover = MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil)
        let gallery = [MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil)]
        let contentBlocks = [
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: nil, thumbnailUrl: nil, altText: nil)),
        ]
        let urls = ImagePreviewUrl.collect(coverImage: cover, gallery: gallery, contentBlocks: contentBlocks)
        XCTAssertTrue(urls.isEmpty)
    }
}
