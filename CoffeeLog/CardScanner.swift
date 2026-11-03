import UIKit

/// 豆のカードの読み取り結果と、どの方法で読んだか
struct CardScanResult: Equatable {
    enum Source: Equatable {
        /// Gemini で読んだ
        case gemini
    }

    let fields: CardFields
    let source: Source
}

/// 豆のカードを Gemini で読む
struct CardScanner {
    /// Gemini での読み取り。API キーがなければ nil
    var gemini: ((UIImage) async throws -> CardFields)?
    /// 端末内（Vision ＋見出し語）での読み取り
    var onDevice: (UIImage) async throws -> CardFields

    func read(_ image: UIImage) async throws -> CardScanResult {
        CardScanResult(fields: try await gemini!(image), source: .gemini)
    }
}
