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
        (\.origin, ["生産国", "産地", "国", "Country", "Origin"]),
        (\.region, ["生産地域", "地域", "地区", "エリア", "Region", "Area"]),
        (\.farm, ["農園", "生産者", "農家", "Farm", "Producer", "Estate"]),
        (\.variety, ["品種", "Varietal", "Variety", "Varieties", "Cultivar"]),
        (\.process, ["精製方法", "精製", "生産処理", "プロセス", "Processing", "Process"]),
        (\.altitude, ["標高", "高度", "Altitude", "Elevation"]),
        (\.tastingNotes, ["テイスティングノート", "フレーバー", "風味", "Tasting Notes", "Flavor Notes", "Flavour", "Flavor", "Cup Notes"]),
    ]

    private static let roastLabels = ["焙煎度", "焙煎", "Roast Level", "Roast"]

    /// 文字認識の結果（位置付きの文字のかたまり）から項目を取り出す
    static func parse(_ texts: [RecognizedText]) -> CardFields {
        parse(lines: CardTextRows.lines(from: texts))
    }

    private static func parse(lines: [String]) -> CardFields {
        var fields = CardFields()
        for index in lines.indices {
            for (field, labels) in Self.labels where fields[keyPath: field] == nil {
                // 同じ項目が何度も出たら最初の値を使う
                fields[keyPath: field] = value(for: labels, at: index, in: lines)
            }
            if fields.roast == nil {
                fields.roast = value(for: roastLabels, at: index, in: lines).flatMap(roast(from:))
            }
        }
        return fields
    }

    /// index の行が見出し語で始まっていれば、その値を返す
    private static func value(for labels: [String], at index: Int, in lines: [String]) -> String? {
        guard let match = labels.lazy.compactMap({ match($0, in: lines[index]) }).first else { return nil }
        switch match {
        case .value(let value):
            return value
        case .labelOnly:
            // 見出し語だけの行なら、値は次の行に書かれている。次の行も見出し語なら値ではない
            guard index + 1 < lines.count, !isLabelLine(lines[index + 1]) else { return nil }
            return lines[index + 1].nilIfBlank
        }
    }

    private static func isLabelLine(_ line: String) -> Bool {
        (labels.flatMap(\.labels) + roastLabels).contains { match($0, in: line) != nil }
    }

    /// カードの焙煎度をアプリの 4 段階に読み替える。中深を中・深より先に見る
    private static func roast(from text: String) -> Roast? {
        let text = text.lowercased()
        let candidates: [(Roast, [String])] = [
            (.mediumDark, ["中深", "medium-dark", "medium dark"]),
            (.light, ["浅", "light"]),
            (.dark, ["深", "dark"]),
            (.medium, ["中", "medium"]),
        ]
        return candidates.first { _, words in words.contains { text.contains($0) } }?.0
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
        // 「Farmhouse」「農園主」のように文字が続くものは見出し語ではない。直後は区切りか行末
        if let next = line[range.upperBound...].unicodeScalars.first, !separators.contains(next) {
            return nil
        }
        let rest = line[range.upperBound...].trimmingCharacters(in: separators)
        return rest.nilIfBlank.map(Match.value) ?? .labelOnly
    }
}
