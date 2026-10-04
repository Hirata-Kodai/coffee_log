import Testing
import UIKit
@testable import CoffeeLog

// TODO（カードの写真から項目を読み取る）
// - [x] 文字を描いたカードの画像から項目を読み取る（Vision の文字認識を実際に通す）
// - [x] 日本語のカードも読み取る
struct CardReaderTests {
    /// 白地に黒い文字で、1 行ずつ描いたカードの画像
    private func cardImage(_ lines: [String]) -> UIImage {
        let size = CGSize(width: 1200, height: 140 * CGFloat(lines.count) + 100)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 64, weight: .medium),
                .foregroundColor: UIColor.black,
            ]
            for (index, line) in lines.enumerated() {
                (line as NSString).draw(at: CGPoint(x: 60, y: 60 + 140 * CGFloat(index)), withAttributes: attributes)
            }
        }
    }

    @Test func 文字を描いたカードの画像から項目を読み取る() async throws {
        let image = cardImage([
            "KENYA NYERI",
            "Region: Nyeri",
            "Farm: Gichathaini",
            "Process: Washed",
            "Roast: Light",
        ])

        let fields = try await CardReader.read(from: image)

        #expect(fields.region == "Nyeri")
        #expect(fields.farm == "Gichathaini")
        #expect(fields.process == "Washed")
        #expect(fields.roast == .light)
    }

    @Test func 日本語のカードも読み取る() async throws {
        let image = cardImage([
            "エチオピア ゲデブ",
            "生産国：エチオピア",
            "農園：ゲデブ",
            "精製方法：ナチュラル",
            "焙煎度：中深煎り",
        ])

        let fields = try await CardReader.read(from: image)

        #expect(fields.origin == "エチオピア")
        #expect(fields.farm == "ゲデブ")
        #expect(fields.process == "ナチュラル")
        #expect(fields.roast == .mediumDark)
    }
}
