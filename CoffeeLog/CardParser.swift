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
    /// 項目ごとの見出し語。長い見出し語を先に並べる（「精製方法」を「精製」より先に見る）
    private static let labels: [(field: WritableKeyPath<CardFields, String?>, labels: [String])] = [
        (\.farm, ["農園", "Farm"]),
        (\.process, ["精製方法", "精製", "Process"]),
    ]

    static func parse(_ lines: [String]) -> CardFields {
        var fields = CardFields()
        for (index, line) in lines.enumerated() {
            for (field, labels) in Self.labels {
                // 同じ項目が何度も出たら最初の値を使う
                guard fields[keyPath: field] == nil else { continue }
                guard let match = labels.lazy.compactMap({ match($0, in: line) }).first else { continue }
                switch match {
                case .value(let value):
                    fields[keyPath: field] = value
                case .labelOnly:
                    // 見出し語だけの行なら、値は次の行に書かれている。次の行も見出し語なら値ではない
                    if index + 1 < lines.count, !isLabelLine(lines[index + 1]) {
                        fields[keyPath: field] = lines[index + 1].nilIfBlank
                    }
                }
            }
        }
        return fields
    }

    private static func isLabelLine(_ line: String) -> Bool {
        labels.contains { $0.labels.contains { match($0, in: line) != nil } }
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
