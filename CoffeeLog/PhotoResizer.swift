import UIKit

/// 写真を保存用のデータにする
enum PhotoResizer {
    static let maxLongSide: CGFloat = 2048
    static let jpegQuality: CGFloat = 0.8

    /// 長辺 2048px を超えるなら縮小し（拡大はしない）、JPEG にする。大きさは画像の倍率を掛けたピクセル数で判断する
    static func jpegData(from image: UIImage) -> Data? {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let ratio = min(1, maxLongSide / max(pixelWidth, pixelHeight))
        let size = CGSize(width: (pixelWidth * ratio).rounded(), height: (pixelHeight * ratio).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: jpegQuality)
    }
}
