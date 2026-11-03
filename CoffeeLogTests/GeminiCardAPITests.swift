import Foundation
import Testing
@testable import CoffeeLog

// TODO（Gemini に豆のカードの画像を送って項目を受け取る）
// - [x] interactions に POST し、API キーはヘッダーで送る
// - [x] 本文にモデル名を入れ、やり取りを Google 側に保存しない（store: false）
// - [x] 指示文とカードの画像（base64 の JPEG）を送る
// - [x] 答えの形（JSON スキーマ）で 8 項目を求め、焙煎度は 4 段階か unknown に限る
// - [x] レスポンスの model_output の JSON から項目を取り出す（thought は読み飛ばす）
// - [x] 空文字の項目は nil にする
// - [x] 焙煎度が 4 段階のどれでもなければ nil
// - [x] 完了していない、答えがない、答えが JSON でないときはエラー
struct GeminiCardAPITests {
    private let image = Data([0xFF, 0xD8, 0xFF, 0x01])

    /// リクエストの本文を JSON として読む
    private func body(_ request: URLRequest) throws -> [String: Any] {
        let data = try #require(request.httpBody)
        return try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    @Test func interactionsにPOSTしAPIキーはヘッダーで送る() throws {
        let request = try GeminiCardAPI.request(image: image, apiKey: "test-key", model: "gemini-test")

        #expect(request.url?.absoluteString == "https://generativelanguage.googleapis.com/v1beta/interactions")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "x-goog-api-key") == "test-key")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func 本文にモデル名を入れGoogle側に保存しない() throws {
        let body = try body(GeminiCardAPI.request(image: image, apiKey: "test-key", model: "gemini-test"))

        #expect(body["model"] as? String == "gemini-test")
        #expect(body["store"] as? Bool == false)
    }

    @Test func 指示文とカードの画像をbase64のJPEGで送る() throws {
        let body = try body(GeminiCardAPI.request(image: image, apiKey: "test-key", model: "gemini-test"))
        let input = try #require(body["input"] as? [[String: Any]])

        #expect(input.count == 2)
        #expect(input[0]["type"] as? String == "text")
        #expect((input[0]["text"] as? String)?.contains("豆のカード") == true)
        #expect(input[1]["type"] as? String == "image")
        #expect(input[1]["mime_type"] as? String == "image/jpeg")
        #expect(input[1]["data"] as? String == image.base64EncodedString())
    }

    @Test func 答えの形で8項目を求め焙煎度は4段階かunknownに限る() throws {
        let body = try body(GeminiCardAPI.request(image: image, apiKey: "test-key", model: "gemini-test"))
        let format = try #require(body["response_format"] as? [String: Any])
        let schema = try #require(format["schema"] as? [String: Any])
        let properties = try #require(schema["properties"] as? [String: [String: Any]])

        #expect(format["type"] as? String == "text")
        #expect(format["mime_type"] as? String == "application/json")
        #expect(schema["type"] as? String == "object")
        let keys = ["origin", "region", "farm", "variety", "process", "altitude", "tasting_notes", "roast"]
        #expect(Set(properties.keys) == Set(keys))
        #expect(Set(schema["required"] as? [String] ?? []) == Set(keys))
        #expect(properties["farm"]?["type"] as? [String] == ["string", "null"])
        #expect(properties["roast"]?["type"] as? String == "string")
        #expect(properties["roast"]?["enum"] as? [String] == ["light", "medium", "mediumDark", "dark", "unknown"])
    }

    /// 2026-11-03 に実際の API から返ったレスポンスの形（thought のあとに model_output）。
    /// 答えの JSON（text）だけをカードの 8 項目に置き換えている
    private func response(status: String = "completed", answer: String) -> Data {
        // 答えの JSON を、レスポンスの JSON の文字列として埋め込めるようにエスケープする
        let escaped = answer
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return Data("""
            {"status":"\(status)","usage":{"total_tokens":147},"created":"2026-11-03T08:46:01Z",
             "steps":[{"signature":"EoEE","type":"thought"},
                      {"content":[{"text":"\(escaped)","type":"text"}],"type":"model_output"}],
             "object":"interaction","model":"gemini-3.8-flash"}
            """.utf8)
    }

    @Test func レスポンスのmodel_outputのJSONから項目を取り出す() throws {
        let data = response(answer: """
            {"origin":"グアテマラ","region":"ウエウエテナンゴ","farm":"エルインヘルト農園","variety":"カトゥアイ",
             "process":"ウォッシュド","altitude":"1500-1900m","tasting_notes":"チョコレート、オレンジ","roast":"medium"}
            """)

        let fields = try GeminiCardAPI.fields(from: data)

        #expect(fields == CardFields(
            origin: "グアテマラ", region: "ウエウエテナンゴ", farm: "エルインヘルト農園", variety: "カトゥアイ",
            process: "ウォッシュド", altitude: "1500-1900m", tastingNotes: "チョコレート、オレンジ", roast: .medium
        ))
    }

    @Test func 空文字の項目はnilにする() throws {
        let data = response(answer: """
            {"origin":"","region":"  ","farm":null,"variety":"カトゥアイ","process":null,"altitude":null,"tasting_notes":null,"roast":"unknown"}
            """)

        let fields = try GeminiCardAPI.fields(from: data)

        #expect(fields == CardFields(variety: "カトゥアイ"))
    }

    @Test(arguments: ["unknown", "mediumLight", "シティ"])
    func 焙煎度が4段階のどれでもなければnil(roast: String) throws {
        let data = response(answer: """
            {"origin":null,"region":null,"farm":null,"variety":null,"process":null,"altitude":null,"tasting_notes":null,"roast":"\(roast)"}
            """)

        #expect(try GeminiCardAPI.fields(from: data).roast == nil)
    }

    @Test func 完了していなければエラー() {
        let data = response(status: "failed", answer: "{}")

        #expect(throws: GeminiCardAPI.ResponseError.notCompleted(status: "failed")) {
            try GeminiCardAPI.fields(from: data)
        }
    }

    @Test func 答えがなければエラー() {
        let data = Data(#"{"status":"completed","steps":[{"signature":"EoEE","type":"thought"}]}"#.utf8)

        #expect(throws: GeminiCardAPI.ResponseError.noAnswer) {
            try GeminiCardAPI.fields(from: data)
        }
    }

    @Test func 答えがJSONでなければエラー() {
        let data = response(answer: "カードが読めませんでした")

        #expect(throws: GeminiCardAPI.ResponseError.invalidAnswer) {
            try GeminiCardAPI.fields(from: data)
        }
    }
}
