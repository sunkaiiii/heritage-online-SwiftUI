import Foundation

struct HeritageApiConfig {
    let baseUrl: String
    let trustSelfSignedCertificates: Bool

    init(baseUrl: String? = nil, trustSelfSignedCertificates: Bool = true) {
        self.baseUrl = baseUrl ?? "https://10.0.2.2:5078"
        self.trustSelfSignedCertificates = trustSelfSignedCertificates
    }
}
