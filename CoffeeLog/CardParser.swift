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
        for line in lines {
            for label in ["農園", "Farm"] {
                if let value = value(of: label, in: line) {
                    fields.farm = value
                }
            }
        }
        return fields
    }

    /// 見出し語のあとの区切り
    private static let separators = CharacterSet(charactersIn: ":：").union(.whitespaces)

    /// 行が見出し語で始まっていれば、区切りを除いた残りを返す
    private static func value(of label: String, in line: String) -> String? {
        // 英語の見出し語は大文字小文字を区別しない
        guard let range = line.range(of: label, options: [.anchored, .caseInsensitive]) else { return nil }
        let rest = line[range.upperBound...].trimmingCharacters(in: separators)
        return rest.nilIfBlank
    }
}
