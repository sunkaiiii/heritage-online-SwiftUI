import XCTest
@testable import HeritageOnline

/// DetailContextDTO 容错解码测试
/// 验证接口字段部分异常时解码不会崩溃
final class DetailContextDecodingTests: XCTestCase {

    // MARK: - 正常解码

    func testDecodeNormalPayload() throws {
        let json = """
        {
            "related": [
                {"id": "a1", "title": "文章1", "type": "article"}
            ],
            "recommendations": [],
            "semanticRecommendations": [],
            "collections": [],
            "exploreTopics": [],
            "graph": []
        }
        """
        let dto = try JSONDecoder().decode(DetailContextDTO.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(dto.related.count, 1)
        XCTAssertEqual(dto.related.first?.id, "a1")
        XCTAssertTrue(dto.recommendations.isEmpty)
    }

    // MARK: - 缺少所有字段

    func testDecodeEmptyPayload() throws {
        let json = "{}"
        let dto = try JSONDecoder().decode(DetailContextDTO.self, from: json.data(using: .utf8)!)
        XCTAssertTrue(dto.related.isEmpty)
        XCTAssertTrue(dto.recommendations.isEmpty)
        XCTAssertTrue(dto.semanticRecommendations.isEmpty)
        XCTAssertTrue(dto.collections.isEmpty)
        XCTAssertTrue(dto.exploreTopics.isEmpty)
        XCTAssertTrue(dto.graph.isEmpty)
    }

    // MARK: - 字段为 null

    func testDecodeNullFields() throws {
        let json = """
        {
            "related": null,
            "recommendations": null,
            "semanticRecommendations": null,
            "collections": null,
            "exploreTopics": null,
            "graph": null
        }
        """
        let dto = try JSONDecoder().decode(DetailContextDTO.self, from: json.data(using: .utf8)!)
        XCTAssertTrue(dto.related.isEmpty)
        XCTAssertTrue(dto.recommendations.isEmpty)
    }

    // MARK: - 数组中部分 item 错误

    func testDecodePartialBadItems() throws {
        let json = """
        {
            "related": [
                {"id": "a1", "title": "ok", "type": "article"},
                {"id": {"bad": "value"}, "title": "bad", "type": "article"},
                {"id": "a2", "title": "ok2", "type": "article"}
            ],
            "recommendations": [],
            "semanticRecommendations": [],
            "collections": [],
            "exploreTopics": [],
            "graph": []
        }
        """
        let dto = try JSONDecoder().decode(DetailContextDTO.self, from: json.data(using: .utf8)!)
        // 应跳过错误 item，保留正确的
        XCTAssertEqual(dto.related.count, 2)
        XCTAssertEqual(dto.related[0].id, "a1")
        XCTAssertEqual(dto.related[1].id, "a2")
    }

    // MARK: - 字段类型错误

    func testDecodeWrongFieldType() throws {
        let json = """
        {
            "related": [],
            "recommendations": [],
            "semanticRecommendations": "unexpected string",
            "collections": [],
            "exploreTopics": [],
            "graph": {}
        }
        """
        let dto = try JSONDecoder().decode(DetailContextDTO.self, from: json.data(using: .utf8)!)
        // 类型错误的字段应返回空数组
        XCTAssertTrue(dto.semanticRecommendations.isEmpty)
        XCTAssertTrue(dto.graph.isEmpty)
    }

    // MARK: - 混合异常

    func testDecodeMixedAnomalies() throws {
        let json = """
        {
            "related": [
                {"id": "a1", "title": "ok", "type": "article"}
            ],
            "recommendations": null,
            "semanticRecommendations": "unexpected",
            "collections": [],
            "exploreTopics": [],
            "graph": {}
        }
        """
        let dto = try JSONDecoder().decode(DetailContextDTO.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(dto.related.count, 1)
        XCTAssertTrue(dto.recommendations.isEmpty)
        XCTAssertTrue(dto.semanticRecommendations.isEmpty)
    }
}
