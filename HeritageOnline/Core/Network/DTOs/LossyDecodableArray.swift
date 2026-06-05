import Foundation

/// 容错数组解码器
/// 当数组中某个元素解码失败时，跳过该元素，保留其余正确元素
/// 避免因为单个 item 格式异常导致整个 DTO 解码失败
struct LossyDecodableArray<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var result: [Element] = []

        while !container.isAtEnd {
            do {
                let value = try container.decode(Element.self)
                result.append(value)
            } catch {
                // 跳过解码失败的元素
                _ = try? container.decode(DiscardedDecodable.self)
            }
        }

        elements = result
    }
}

/// 用于丢弃无法解码的元素
private struct DiscardedDecodable: Decodable {}

// MARK: - KeyedDecodingContainer 扩展

extension KeyedDecodingContainer {
    /// 容错解码可选数组
    /// 字段缺失、为 null、类型错误、数组内部分 item 错误时均返回空数组
    func decodeLossyArrayIfPresent<Element: Decodable>(
        _ type: Element.Type,
        forKey key: Key
    ) -> [Element] {
        do {
            return try decodeIfPresent(LossyDecodableArray<Element>.self, forKey: key)?.elements ?? []
        } catch {
            return []
        }
    }
}
