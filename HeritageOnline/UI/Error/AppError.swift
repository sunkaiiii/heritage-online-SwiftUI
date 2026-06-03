import Foundation

/// 应用统一错误类型
enum AppError: Error, Equatable {
    /// 网络连接错误
    case network
    /// 请求超时
    case timeout
    /// 服务器错误
    case server
    /// 资源不存在
    case notFound
    /// 输入校验错误
    case validationError(String)
    /// 未知错误
    case unknown(String?)

    /// 从 Error 转换
    static func from(_ error: Error) -> AppError {
        // 优先识别 NetworkError
        if let networkError = error as? NetworkError {
            return fromNetworkError(networkError)
        }

        // 处理 NSError
        let nsError = error as NSError

        switch nsError.domain {
        case NSURLErrorDomain:
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return .network
            case NSURLErrorTimedOut:
                return .timeout
            default:
                return .unknown(nsError.localizedDescription)
            }
        default:
            // 检查是否为 HTTP 错误
            if let httpResponse = nsError.userInfo["response"] as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 404:
                    return .notFound
                case 500...599:
                    return .server
                default:
                    return .unknown(nsError.localizedDescription)
                }
            }
            return .unknown(nsError.localizedDescription)
        }
    }

    /// 从 NetworkError 转换
    private static func fromNetworkError(_ error: NetworkError) -> AppError {
        switch error {
        case .networkUnavailable:
            return .network
        case .timeout:
            return .timeout
        case .notFound:
            return .notFound
        case .notFoundWithDetails:
            return .notFound
        case .serverError:
            return .server
        case .serverErrorWithDetails:
            return .server
        case .httpError(let statusCode):
            if statusCode == 404 {
                return .notFound
            } else if statusCode >= 500 {
                return .server
            }
            return .unknown(error.localizedDescription)
        case .badRequest:
            return .unknown(error.localizedDescription)
        case .badRequestWithDetails(let details):
            return .unknown(details?.detail ?? error.localizedDescription)
        case .decodingError(let decodingError):
            return .unknown(decodingError.localizedDescription)
        case .invalidBaseURL, .invalidURL, .invalidResponse:
            return .unknown(error.localizedDescription)
        case .underlying(let underlyingError):
            return .unknown(underlyingError.localizedDescription)
        }
    }

    /// 本地化描述
    var localizedDescription: String {
        switch self {
        case .network:
            return String(localized: "error.network")
        case .timeout:
            return String(localized: "error.timeout")
        case .server:
            return String(localized: "error.server")
        case .notFound:
            return String(localized: "error.notFound")
        case .validationError(let message):
            return message
        case .unknown(let message):
            return message ?? String(localized: "error.unknown")
        }
    }
}
