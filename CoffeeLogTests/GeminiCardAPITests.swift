import Foundation
import Testing
@testable import CoffeeLog

// TODO（Gemini に豆のカードの画像を送って項目を受け取る）
// - [x] interactions に POST し、API キーはヘッダーで送る
// - [ ] 本文にモデル名を入れ、やり取りを Google 側に保存しない（store: false）
// - [ ] 指示文とカードの画像（base64 の JPEG）を送る
// - [ ] 答えの形（JSON スキーマ）で 8 項目を求め、焙煎度は 4 段階か null に限る
// - [ ] レスポンスの model_output の JSON から項目を取り出す（thought は読み飛ばす）
// - [ ] 空文字の項目は nil にする
// - [ ] 焙煎度が 4 段階のどれでもなければ nil
// - [ ] 完了していない、答えがない、答えが JSON でないときはエラー
struct GeminiCardAPITests {
    private let image = Data([0xFF, 0xD8, 0xFF, 0x01])

    @Test func interactionsにPOSTしAPIキーはヘッダーで送る() throws {
        let request = try GeminiCardAPI.request(image: image, apiKey: "test-key", model: "gemini-test")

        #expect(request.url?.absoluteString == "https://generativelanguage.googleapis.com/v1beta/interactions")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "x-goog-api-key") == "test-key")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }
}
