import UIKit

/// 写真を保存用のデータにする
enum PhotoResizer {
    static let maxLongSide: CGFloat = 2048

    static func jpegData(from image: UIImage) -> Data? {
        let ratio = maxLongSide / max(image.size.width, image.size.height)
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.pngData()
    }
}
