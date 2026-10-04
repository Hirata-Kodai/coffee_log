import Foundation

/// 豆のカードから読み取った項目。読めなかった項目は nil
struct CardFields: Equatable {
    var origin: String?
    var region: String?
    var farm: String?
    var variety: String?
    var process: String?
    var altitude: String?
    var tastingNotes: String?
    var roast: Roast?
}

/// カードの文字（上から順の行）から、見出し語を手がかりに項目を取り出す
enum CardParser {
    static func parse(_ lines: [String]) -> CardFields {
        var fields = CardFields()
        for line in lines where line.hasPrefix("農園：") {
            fields.farm = String(line.dropFirst("農園：".count))
        }
        return fields
    }
}
