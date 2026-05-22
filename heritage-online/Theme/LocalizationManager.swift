import Foundation
import SwiftUI

@MainActor
@Observable
class LocalizationManager {
    private var translations: [String: String] = [:]
    private(set) var currentLanguage: String = ""

    init() {
        let preferred = Bundle.main.preferredLocalizations.first ?? "en"
        load(language: preferred)
    }

    func localized(_ key: String) -> String {
        translations[key] ?? key
    }

    func setLanguage(_ language: String) {
        guard language != currentLanguage else { return }
        load(language: language)
    }

    private func load(language: String) {
        currentLanguage = language
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            translations = dict
        } else if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "en"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            translations = dict
        } else {
            translations = [:]
        }
    }
}
