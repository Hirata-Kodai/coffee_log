import CoreGraphics
import Testing
@testable import CoffeeLog

// TODO（文字認識の結果を行にまとめる）
// - [x] 上から下の順に並べる（位置は Vision と同じく左下が原点）
// - [x] 同じ高さの文字は左から右に 1 行にまとめる
// - [x] 少し傾いて上下にずれていても同じ行と見なす
struct CardTextRowsTests {
    /// 高さ 0.04 の文字のかたまり。y は下端
    private func text(_ string: String, x: CGFloat, y: CGFloat) -> RecognizedText {
        RecognizedText(text: string, box: CGRect(x: x, y: y, width: 0.2, height: 0.04))
    }

    @Test func 上から下の順に並べる() {
        let rows = CardTextRows.lines(from: [
            text("農園：ゲデブ", x: 0.1, y: 0.5),
            text("生産国：エチオピア", x: 0.1, y: 0.8),
        ])

        #expect(rows == ["生産国：エチオピア", "農園：ゲデブ"])
    }

    @Test func 同じ高さの文字は左から右に1行にまとめる() {
        let rows = CardTextRows.lines(from: [
            text("ゲデブ", x: 0.5, y: 0.5),
            text("生産国", x: 0.1, y: 0.8),
            text("農園", x: 0.1, y: 0.5),
            text("エチオピア", x: 0.5, y: 0.8),
        ])

        #expect(rows == ["生産国 エチオピア", "農園 ゲデブ"])
    }

    @Test func 少し傾いて上下にずれていても同じ行と見なす() {
        let rows = CardTextRows.lines(from: [
            text("農園", x: 0.1, y: 0.5),
            text("ゲデブ", x: 0.5, y: 0.515),
            text("精製方法", x: 0.1, y: 0.42),
        ])

        #expect(rows == ["農園 ゲデブ", "精製方法"])
    }
}
