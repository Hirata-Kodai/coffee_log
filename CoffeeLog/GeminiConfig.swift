import Foundation

/// Gemini の API キーとモデル名。Info.plist（ビルド設定 Config/App.xcconfig から入る）から読む
struct GeminiConfig: Equatable {
    let apiKey: String
    let model: String

    init(apiKey: String, model: String) {
        self.apiKey = apiKey
        self.model = model
    }

    init?(info: [String: Any]) {
        guard let apiKey = info["GeminiAPIKey"] as? String, let model = info["GeminiModel"] as? String else {
            return nil
        }
        self.init(apiKey: apiKey, model: model)
    }
}
