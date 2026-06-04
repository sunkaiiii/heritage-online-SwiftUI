import XCTest
@testable import HeritageOnline

/// ReadingPathRepository 单元测试
/// 覆盖：记录、重复 id 更新时间、上限裁剪、清空
@preconcurrency @MainActor
final class ReadingPathRepositoryTests: XCTestCase {
    var repository: DefaultReadingPathRepository!

    override func setUp() {
        super.setUp()
        clearTestData()
        repository = DefaultReadingPathRepository.shared
    }

    override func tearDown() {
        clearTestData()
        super.tearDown()
    }

    // MARK: - 记录

    func testRecordAddsNewEvent() async {
        // Given
        let event = createEvent(fromId: "a1", toId: "d1")

        // When
        await repository.record(event)

        // Then
        let events = await repository.events()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.fromId, "a1")
        XCTAssertEqual(events.first?.toId, "d1")
    }

    func testRecordDuplicateUpdatesCreatedAt() async {
        // Given - 先记录一次
        let event = createEvent(fromId: "a1", toId: "d1")
        await repository.record(event)
        let events1 = await repository.events()
        let firstCreatedAt = events1.first!.createdAt

        // When - 等待一小段时间后再次记录相同 id
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        await repository.record(event)

        // Then - 仍然只有一条记录，但 createdAt 已更新
        let events2 = await repository.events()
        XCTAssertEqual(events2.count, 1)
        XCTAssertGreaterThan(events2.first!.createdAt, firstCreatedAt)
    }

    func testRecordDifferentIdsAddsMultiple() async {
        // Given
        let event1 = createEvent(fromId: "a1", toId: "d1")
        let event2 = createEvent(fromId: "a2", toId: "d2")

        // When
        await repository.record(event1)
        await repository.record(event2)

        // Then
        let events = await repository.events()
        XCTAssertEqual(events.count, 2)
    }

    func testRecordInsertsAtHead() async {
        // Given
        let event1 = createEvent(fromId: "a1", toId: "d1")
        let event2 = createEvent(fromId: "a2", toId: "d2")

        // When
        await repository.record(event1)
        await repository.record(event2)

        // Then - 最新记录在前
        let events = await repository.events()
        XCTAssertEqual(events[0].fromId, "a2")
        XCTAssertEqual(events[1].fromId, "a1")
    }

    // MARK: - 上限裁剪

    func testRecordTrimsToMaxEvents() async {
        // Given - 记录超过上限（50条）
        for i in 0..<55 {
            let event = createEvent(fromId: "a\(i)", toId: "d\(i)")
            await repository.record(event)
        }

        // Then - 裁剪到 50 条
        let events = await repository.events()
        XCTAssertEqual(events.count, 50)
        // 最早的几条应被裁剪
        XCTAssertEqual(events.first?.fromId, "a54")
        XCTAssertEqual(events.last?.fromId, "a5")
    }

    // MARK: - 清空

    func testClearAllRemovesAllEvents() async {
        // Given
        let event1 = createEvent(fromId: "a1", toId: "d1")
        let event2 = createEvent(fromId: "a2", toId: "d2")
        await repository.record(event1)
        await repository.record(event2)

        // When
        await repository.clearAll()

        // Then
        let events = await repository.events()
        XCTAssertTrue(events.isEmpty)
    }

    // MARK: - 持久化

    func testEventsPersistAcrossInstances() async {
        // Given
        let event = createEvent(fromId: "a1", toId: "d1")
        await repository.record(event)

        // When - 新建实例（模拟重启）
        let newRepository = DefaultReadingPathRepository.shared

        // Then
        let events = await newRepository.events()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.fromId, "a1")
    }

    // MARK: - 空状态

    func testEventsEmptyByDefault() async {
        let events = await repository.events()
        XCTAssertTrue(events.isEmpty)
    }

    // MARK: - Helpers

    private func createEvent(fromId: String, toId: String) -> ReadingPathEvent {
        ReadingPathEvent(
            id: ReadingPathEvent.computeId(
                fromType: .article,
                fromId: fromId,
                toType: .directoryItem,
                toId: toId,
                source: .related
            ),
            fromType: .article,
            fromId: fromId,
            fromTitle: "From \(fromId)",
            toType: .directoryItem,
            toId: toId,
            toTitle: "To \(toId)",
            source: .related,
            toCategory: nil,
            toKind: nil,
            toSourceId: nil,
            toSourceUrl: nil,
            toSubtitle: nil,
            toImageUrl: nil,
            createdAt: Date()
        )
    }

    private func clearTestData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "reading_path_events")
        defaults.synchronize()
    }
}
