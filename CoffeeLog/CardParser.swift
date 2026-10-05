import CoreGraphics
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
        (\.origin, ["生豆生産国", "生産国", "産地", "国", "Country", "Origin"]),
        (\.region, ["生産地域", "地域", "地区", "エリア", "Region", "Area"]),
        (\.farm, ["農園", "生産者", "農家", "Farm", "Producer", "Estate"]),
        (\.variety, ["品種", "Varietal", "Variety", "Varieties", "Cultivar"]),
        (\.process, ["精製方法", "精製", "精選", "生産処理", "プロセス", "Processing", "Process"]),
        (\.altitude, ["標高", "高度", "Altitude", "Elevation"]),
        (\.tastingNotes, ["テイスティングノート", "フレーバー", "風味", "Tasting Notes", "Flavor Notes", "Flavour", "Flavor", "Cup Notes"]),
    ]

    private static let roastLabels = ["焙煎度", "焙煎", "Roast Level", "Roast"]

    /// 文字認識の結果（位置付きの文字のかたまり）から項目を取り出す
    static func parse(_ texts: [RecognizedText]) -> CardFields {
        // 上から順（左下が原点なので y が大きいほど上）、同じ高さなら左から
        let ordered = texts.sorted { ($0.box.midY, -$0.box.minX) > ($1.box.midY, -$1.box.minX) }
        var fields = CardFields()
        for (field, labels) in Self.labels {
            fields[keyPath: field] = preferredValue(ordered.compactMap { value(for: labels, at: $0, in: ordered) })
        }
        fields.roast = preferredValue(ordered.compactMap { value(for: roastLabels, at: $0, in: ordered) })
            .flatMap(roast(from:))
        return fields
    }

    /// 日英の両方が書かれたカードでは日本語の値を使う。それ以外は最初に出た値
    private static func preferredValue(_ values: [String]) -> String? {
        values.first(where: containsJapanese) ?? values.first
    }

    private static func containsJapanese(_ string: String) -> Bool {
        string.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x3040...0x30FF, 0x4E00...0x9FFF: true  // ひらがな・カタカナ・漢字
            default: false
            }
        }
    }

    /// text が見出し語で始まっていれば、その値を返す。値は同じかたまりの残り、右隣、真下の順に探す（見出しのかたまりは値にしない）
    private static func value(for labels: [String], at text: RecognizedText, in texts: [RecognizedText]) -> String? {
        guard let match = labels.lazy.compactMap({ match($0, in: text.text) }).first else { return nil }
        if case .value(let value) = match {
            return value
        }
        let neighbors = [nearestRight(text, in: texts), nearestBelow(text, in: texts)]
        return neighbors.lazy.compactMap { $0 }.first { !isLabel($0.text) }?.text.nilIfBlank
    }

    /// 同じ高さで右にある一番近いかたまり（表形式のカード）
    private static func nearestRight(_ text: RecognizedText, in texts: [RecognizedText]) -> RecognizedText? {
        texts
            .filter { $0 != text && $0.box.minX >= text.box.maxX && isSameRow($0, text) }
            .min { $0.box.minX < $1.box.minX }
    }

    /// 縦の中心のずれが、低いほうのかたまりの高さの半分より小さければ同じ行（少しの傾きを許す）
    private static func isSameRow(_ a: RecognizedText, _ b: RecognizedText) -> Bool {
        abs(a.box.midY - b.box.midY) < min(a.box.height, b.box.height) / 2
    }

    /// 真下にある一番近いかたまり。横位置が重なり、見出しの高さの 1.5 倍より近いものに限る
    private static func nearestBelow(_ text: RecognizedText, in texts: [RecognizedText]) -> RecognizedText? {
        texts
            .filter { other in
                let gap = text.box.minY - other.box.maxY
                let overlaps = other.box.minX < text.box.maxX && text.box.minX < other.box.maxX
                return other != text && overlaps && gap >= -text.box.height / 2 && gap < text.box.height * 1.5
            }
            .max { $0.box.maxY < $1.box.maxY }
    }

    private static func isLabel(_ string: String) -> Bool {
        (labels.flatMap(\.labels) + roastLabels).contains { match($0, in: string) != nil }
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
