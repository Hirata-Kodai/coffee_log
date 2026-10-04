import CoreGraphics

/// 文字認識で見つかった文字のかたまり。box は画像に対する割合で、Vision と同じく左下が原点
struct RecognizedText: Equatable {
    let text: String
    let box: CGRect
}

/// 文字のかたまりを、カードの見た目どおりの行に並べる
enum CardTextRows {
    static func lines(from texts: [RecognizedText]) -> [String] {
        // 左下が原点なので、y が大きいほど上
        texts.sorted { $0.box.midY > $1.box.midY }.map(\.text)
    }
}
