import UIKit

/// 豆のカードの読み取り結果と、どの方法で読んだか
struct CardScanResult: Equatable {
    enum Source: Equatable {
        /// Gemini で読んだ
        case gemini
        /// Gemini が失敗したので、端末内の読み取りに切り替えた
        case onDeviceFallback
        /// Gemini が使えない（API キーがない）ので、端末内で読んだ
        case onDevice
    }

    let fields: CardFields
    let source: Source
}

/// 豆のカードを Gemini で読む。失敗したら端末内の読み取りに切り替える
struct CardScanner {
    /// Gemini での読み取り。API キーがなければ nil
    var gemini: ((UIImage) async throws -> CardFields)?
    /// 端末内（Vision ＋見出し語）での読み取り
    var onDevice: (UIImage) async throws -> CardFields

    func read(_ image: UIImage) async throws -> CardScanResult {
        guard let gemini else {
            return CardScanResult(fields: try await onDevice(image), source: .onDevice)
        }
        do {
            return CardScanResult(fields: try await gemini(image), source: .gemini)
        } catch {
            // 通信できない、上限に達した、答えが読めないなど
            #if DEBUG
            print("[CardScanner] Gemini で読めなかったため端末内で読みます:", error)
            #endif
            return CardScanResult(fields: try await onDevice(image), source: .onDeviceFallback)
        }
    }
}

extension CardScanner {
    /// アプリで使う読み取り。API キーが Info.plist にあれば Gemini を使う
    static var live: CardScanner {
        let config = GeminiConfig(info: Bundle.main.infoDictionary ?? [:])
        return CardScanner(
            gemini: config.map { config in { image in try await GeminiCardAPI.read(image, config: config) } },
            onDevice: { image in try await CardReader.read(from: image) }
        )
    }
}
