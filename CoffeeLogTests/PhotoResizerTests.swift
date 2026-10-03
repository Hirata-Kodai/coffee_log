import Testing
import UIKit
@testable import CoffeeLog

// TODO（保存前の写真の縮小）
// - [x] 長辺が 2048px を超える横長の写真は長辺 2048px に縮小し、縦横比を保つ
// - [x] 縦長の写真も長辺 2048px に縮小する
// - [x] 長辺が 2048px 以下なら拡大しない
// - [x] JPEG で保存する
struct PhotoResizerTests {
    /// 指定したピクセル数の単色画像
    private func image(width: Int, height: Int) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { context in
            UIColor.brown.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    /// 保存用データを読み直したときのピクセル数
    private func pixelSize(of data: Data) throws -> CGSize {
        let image = try #require(UIImage(data: data))
        let cgImage = try #require(image.cgImage)
        return CGSize(width: cgImage.width, height: cgImage.height)
    }

    @Test func 長辺が2048pxを超える横長の写真は長辺2048pxに縮小し縦横比を保つ() throws {
        let data = try #require(PhotoResizer.jpegData(from: image(width: 4000, height: 3000)))

        #expect(try pixelSize(of: data) == CGSize(width: 2048, height: 1536))
    }

    @Test func 縦長の写真も長辺2048pxに縮小する() throws {
        let data = try #require(PhotoResizer.jpegData(from: image(width: 3000, height: 4000)))

        #expect(try pixelSize(of: data) == CGSize(width: 1536, height: 2048))
    }

    @Test func 長辺が2048px以下なら拡大しない() throws {
        let data = try #require(PhotoResizer.jpegData(from: image(width: 1000, height: 500)))

        #expect(try pixelSize(of: data) == CGSize(width: 1000, height: 500))
    }

    @Test func JPEGで保存する() throws {
        let data = try #require(PhotoResizer.jpegData(from: image(width: 100, height: 100)))

        // JPEG の先頭は FF D8 FF
        #expect(Array(data.prefix(3)) == [0xFF, 0xD8, 0xFF])
    }
}
