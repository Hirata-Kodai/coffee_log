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
            input: [.text(instruction), .jpeg(image)],
            responseFormat: .cardFields
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
        let responseFormat: ResponseFormat
        /// カードの写真を Google 側に残さない
        let store = false

        enum CodingKeys: String, CodingKey {
            case model, input, store
            case responseFormat = "response_format"
        }
    }

    /// 焙煎度の答えの選択肢。unknown は「書かれていない・中間で決められない」
    static let roastChoices = ["light", "medium", "mediumDark", "dark", "unknown"]

    /// 答えの形（JSON スキーマ）
    private struct ResponseFormat: Encodable {
        let type = "text"
        let mimeType = "application/json"
        let schema: Schema

        enum CodingKeys: String, CodingKey {
            case type, schema
            case mimeType = "mime_type"
        }

        static let cardFields: Self = {
            let texts: [(key: String, description: String)] = [
                ("origin", "生産国"),
                ("region", "生産国より細かい産地（地域）"),
                ("farm", "農園・生産者"),
                ("variety", "品種"),
                ("process", "精製方法"),
                ("altitude", "標高"),
                ("tasting_notes", "テイスティングノート・フレーバー（店の説明にある風味）"),
            ]
            var properties = Dictionary(uniqueKeysWithValues: texts.map {
                ($0.key, Property(type: .nullableString, description: $0.description))
            })
            properties["roast"] = Property(type: .string, description: "焙煎度", enum: roastChoices)
            return ResponseFormat(schema: Schema(properties: properties, required: texts.map(\.key) + ["roast"]))
        }()
    }

    private struct Schema: Encodable {
        let type = "object"
        let properties: [String: Property]
        let required: [String]
    }

    private struct Property: Encodable {
        let type: PropertyType
        let description: String
        var `enum`: [String]? = nil
    }

    private enum PropertyType: Encodable {
        case string
        /// 書かれていなければ null
        case nullableString

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string: try container.encode("string")
            case .nullableString: try container.encode(["string", "null"])
            }
        }
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

extension GeminiCardAPI {
    /// レスポンスから、モデルの答え（model_output の JSON）を読んで項目にする
    static func fields(from data: Data) throws -> CardFields {
        let interaction = try JSONDecoder().decode(Interaction.self, from: data)
        let output = interaction.steps?.first { $0.type == "model_output" }
        let text = output?.content?.first { $0.type == "text" }?.text ?? ""
        let answer = try JSONDecoder().decode(Answer.self, from: Data(text.utf8))
        return CardFields(
            origin: answer.origin,
            region: answer.region,
            farm: answer.farm,
            variety: answer.variety,
            process: answer.process,
            altitude: answer.altitude,
            tastingNotes: answer.tastingNotes,
            roast: answer.roast.flatMap(Roast.init(rawValue:))
        )
    }

    private struct Interaction: Decodable {
        let status: String
        let steps: [Step]?
    }

    /// 思考（thought）や答え（model_output）などの 1 段階
    private struct Step: Decodable {
        let type: String
        let content: [Content]?
    }

    private struct Content: Decodable {
        let type: String
        let text: String?
    }

    /// 答えの JSON（キーは送ったスキーマのもの）
    private struct Answer: Decodable {
        let origin: String?
        let region: String?
        let farm: String?
        let variety: String?
        let process: String?
        let altitude: String?
        let tastingNotes: String?
        let roast: String?

        enum CodingKeys: String, CodingKey {
            case origin, region, farm, variety, process, altitude, roast
            case tastingNotes = "tasting_notes"
        }
    }
}
