import Foundation

/// Gemini（Interactions API）に豆のカードの画像を送り、読み取った項目を受け取る。通信そのものは呼び出し側で行う
enum GeminiCardAPI {
    static let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/interactions")!

    static func request(image: Data, apiKey: String, model: String) throws -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
