import Foundation

/// Gemini（Interactions API）に豆のカードの画像を送り、読み取った項目を受け取る。通信そのものは呼び出し側で行う
enum GeminiCardAPI {
    static let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/interactions")!

    static func request(image: Data, apiKey: String, model: String) throws -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RequestBody(
            model: model,
            input: [.text(instruction), .jpeg(image)]
        ))
        return request
    }

    /// モデルへの指示。値の決め方（日本語優先、焙煎度の読み替え）はアプリの決定に合わせる
    static let instruction = """
        これはコーヒー豆に添えられた豆のカード（産地や精製方法が書かれたカード）の写真です。
        カードに書かれている情報から、各項目の値を取り出してください。
        - カードに書かれていない項目は null にしてください。推測で埋めないでください。
        - 日本語と英語の両方で書かれている場合は、日本語の表記を使ってください。
        - 値はカードの表記どおりに書き写してください（標高の単位なども含めます）。
        - 焙煎度は light（浅煎り）、medium（中煎り）、mediumDark（中深煎り）、dark（深煎り）のどれかにしてください。
          ミディアムライトや中浅煎りのような中間のもの、どれとも決められないものは null にしてください。
        """

    /// Interactions API に送る本文
    private struct RequestBody: Encodable {
        let model: String
        let input: [InputContent]
        /// カードの写真を Google 側に残さない
        let store = false
    }

    private struct InputContent: Encodable {
        let type: String
        var text: String?
        var data: String?
        var mimeType: String?

        enum CodingKeys: String, CodingKey {
            case type, text, data
            case mimeType = "mime_type"
        }

        static func text(_ text: String) -> Self {
            InputContent(type: "text", text: text)
        }

        static func jpeg(_ data: Data) -> Self {
            InputContent(type: "image", data: data.base64EncodedString(), mimeType: "image/jpeg")
        }
    }
}
