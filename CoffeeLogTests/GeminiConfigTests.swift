import Testing
@testable import CoffeeLog

// TODO（Info.plist から Gemini の設定を読む）
// - [x] API キーとモデル名があれば設定を作る
// - [ ] API キーが空、ビルド設定の値のまま（$(...)）、項目がなければ作らない
// - [ ] モデル名がなければ既定のモデルを使う
struct GeminiConfigTests {
    @Test func APIキーとモデル名があれば設定を作る() {
        let config = GeminiConfig(info: ["GeminiAPIKey": "test-key", "GeminiModel": "gemini-test"])

        #expect(config == GeminiConfig(apiKey: "test-key", model: "gemini-test"))
    }
}
