import Foundation

/// 发现页区块状态
/// 对齐 Android DiscoverySectionState
struct DiscoverySectionState<T> {
    let isLoading: Bool
    let data: T?
    let error: AppError?

    init(isLoading: Bool = false, data: T? = nil, error: AppError? = nil) {
        self.isLoading = isLoading
        self.data = data
        self.error = error
    }

    /// 是否有数据
    var hasData: Bool { data != nil }

    /// 是否有错误（且没有数据）
    var hasError: Bool { error != nil && !hasData }

    /// 创建加载中状态
    func loading() -> DiscoverySectionState<T> {
        DiscoverySectionState(isLoading: true, data: data, error: nil)
    }

    /// 创建成功状态
    func success(_ newData: T) -> DiscoverySectionState<T> {
        DiscoverySectionState(isLoading: false, data: newData, error: nil)
    }

    /// 创建错误状态
    func failed(_ error: AppError) -> DiscoverySectionState<T> {
        DiscoverySectionState(isLoading: false, data: data, error: error)
    }
}
