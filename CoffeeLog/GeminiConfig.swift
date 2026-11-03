import Foundation

/// Gemini の API キーとモデル名。Info.plist（ビルド設定 Config/App.xcconfig から入る）から読む
struct GeminiConfig: Equatable {
    /// Info.plist にモデル名がないときに使う（Config/App.xcconfig の既定値と同じ）
    static let defaultModel = "gemini-3.8-flash"

    let apiKey: String
    let model: String

    init(apiKey: String, model: String) {
        self.apiKey = apiKey
        self.model = model
    }

    /// API キーがなければ nil（Gemini を使わず端末内で読む）
    init?(info: [String: Any]) {
        guard let apiKey = Self.value(info["GeminiAPIKey"]) else { return nil }
        self.init(apiKey: apiKey, model: Self.value(info["GeminiModel"]) ?? Self.defaultModel)
    }

    /// 空欄や、ビルド設定が置き換わらずに残った「$(...)」は値なしと見なす
    private static func value(_ raw: Any?) -> String? {
        guard let string = (raw as? String)?.nilIfBlank, !string.hasPrefix("$(") else { return nil }
        return string
    }
}
