import ImageIO
import UIKit
import Vision

/// 豆のカードの写真から、文字認識（端末内の Vision）で項目を読み取る
enum CardReader {
    enum ReadError: Error {
        case unreadableImage
    }

    static func read(from image: UIImage) async throws -> CardFields {
        guard let cgImage = image.cgImage else { throw ReadError.unreadableImage }
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        // 農園名・品種などは辞書にない固有名詞が多いので、言語補正で別の語に寄せない
        request.usesLanguageCorrection = false
        request.recognitionLanguages = [Locale.Language(identifier: "ja-JP"), Locale.Language(identifier: "en-US")]
        let observations = try await request.perform(on: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        let texts = observations.compactMap { observation in
            observation.topCandidates(1).first.map {
                RecognizedText(text: $0.string, box: observation.boundingBox.cgRect)
            }
        }
        return CardParser.parse(texts)
    }
}

private extension CGImagePropertyOrientation {
    /// カメラで撮った写真は向きの情報を持つので、文字認識に渡す
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
