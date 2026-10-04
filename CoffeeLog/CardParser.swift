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
        for (index, line) in lines.enumerated() {
            for label in ["農園", "Farm"] {
                switch match(label, in: line) {
                case .value(let value):
                    fields.farm = value
                case .labelOnly:
                    // 見出し語だけの行なら、値は次の行に書かれている
                    if index + 1 < lines.count {
                        fields.farm = lines[index + 1].nilIfBlank
                    }
                case nil:
                    break
                }
            }
        }
        return fields
    }

    private enum Match {
        /// 見出し語と同じ行に値がある
        case value(String)
        /// 見出し語だけの行
        case labelOnly
    }

    /// 見出し語のあとの区切り
    private static let separators = CharacterSet(charactersIn: ":：").union(.whitespaces)

    /// 行が見出し語で始まっているか。始まっていれば、同じ行の値（区切りを除いた残り）があるかどうかを返す
    private static func match(_ label: String, in line: String) -> Match? {
        // 英語の見出し語は大文字小文字を区別しない
        guard let range = line.range(of: label, options: [.anchored, .caseInsensitive]) else { return nil }
        let rest = line[range.upperBound...].trimmingCharacters(in: separators)
        return rest.nilIfBlank.map(Match.value) ?? .labelOnly
    }
}
