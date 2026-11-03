import Testing
@testable import CoffeeLog

// TODO（Info.plist から Gemini の設定を読む）
// - [x] API キーとモデル名があれば設定を作る
// - [x] API キーが空、ビルド設定の値のまま（$(...)）、項目がなければ作らない
// - [x] モデル名がなければ既定のモデルを使う
struct GeminiConfigTests {
    @Test func APIキーとモデル名があれば設定を作る() {
        let config = GeminiConfig(info: ["GeminiAPIKey": "test-key", "GeminiModel": "gemini-test"])

        #expect(config == GeminiConfig(apiKey: "test-key", model: "gemini-test"))
    }

    @Test(arguments: ["", "  ", "$(GEMINI_API_KEY)"])
    func APIキーが空かビルド設定の値のままなら作らない(apiKey: String) {
        #expect(GeminiConfig(info: ["GeminiAPIKey": apiKey, "GeminiModel": "gemini-test"]) == nil)
    }

    @Test func APIキーの項目がなければ作らない() {
        #expect(GeminiConfig(info: ["GeminiModel": "gemini-test"]) == nil)
    }

    @Test(arguments: [nil, "", "$(GEMINI_MODEL)"] as [String?])
    func モデル名がなければ既定のモデルを使う(model: String?) {
        var info: [String: Any] = ["GeminiAPIKey": "test-key"]
        info["GeminiModel"] = model

        #expect(GeminiConfig(info: info)?.model == GeminiConfig.defaultModel)
    }
}
