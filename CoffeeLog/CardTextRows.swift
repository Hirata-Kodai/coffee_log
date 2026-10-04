import CoreGraphics

/// 文字認識で見つかった文字のかたまり。box は画像に対する割合で、Vision と同じく左下が原点
struct RecognizedText: Equatable {
    let text: String
    let box: CGRect
}

/// 文字のかたまりを、カードの見た目どおりの行に並べる
enum CardTextRows {
    static func lines(from texts: [RecognizedText]) -> [String] {
        var rows: [[RecognizedText]] = []
        // 左下が原点なので、y が大きいほど上。上から順に、同じ行に入るかを見る
        for text in texts.sorted(by: { $0.box.midY > $1.box.midY }) {
            if let last = rows.last?.first, isSameRow(last, text) {
                rows[rows.count - 1].append(text)
            } else {
                rows.append([text])
            }
        }
        return rows.map { row in
            row.sorted { $0.box.minX < $1.box.minX }.map(\.text).joined(separator: " ")
        }
    }

    /// 縦の中心のずれが、低いほうの文字の高さの半分より小さければ同じ行（少しの傾きを許す）
    private static func isSameRow(_ a: RecognizedText, _ b: RecognizedText) -> Bool {
        abs(a.box.midY - b.box.midY) < min(a.box.height, b.box.height) / 2
    }
}
