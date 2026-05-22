import Foundation

struct HeritageApiConfig {
    let baseUrl: String
    let trustSelfSignedCertificates: Bool

    init(baseUrl: String? = nil, trustSelfSignedCertificates: Bool = true) {
        #if os(macOS)
        let defaultUrl = "https://localhost:5078"
        #elseif targetEnvironment(simulator)
        let defaultUrl = "https://localhost:5078"
        #else
        let defaultUrl = "https://192.168.1.61:5078"
        #endif
        self.baseUrl = baseUrl ?? defaultUrl
        self.trustSelfSignedCertificates = trustSelfSignedCertificates
    }
}
