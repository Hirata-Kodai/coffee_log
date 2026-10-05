import CoreGraphics
import Testing
@testable import CoffeeLog

// TODO（豆のカードの文字から項目を取り出す）
// - [x] 見出し語と同じ行の値を取り出す（「農園：ゲデブ」）
// - [x] 見出し語のあとの区切りは全角・半角のコロンと空白
// - [x] 英語の見出し語は大文字小文字を区別しない（「FARM Gedeb」）
// - [x] 見出し語だけの行なら、次の行を値にする
// - [x] 次の行も見出し語なら、値にしない
// - [x] 同じ項目が何度も出たら最初の値を使う
// - [x] 見出し語のすぐあとに文字が続くものは見出し語と見なさない（「Regional」）
// - [x] 文字列の 7 項目それぞれの見出し語を読む
// - [x] 焙煎度はアプリの 4 段階に読み替え、読み替えられなければ nil
struct CardParserTests {
    /// 1 行を 1 つの文字のかたまりとして、上から順に縦に積む（位置は左下が原点の割合）
    private func stacked(_ lines: [String]) -> [RecognizedText] {
        lines.enumerated().map { index, line in
            RecognizedText(text: line, box: CGRect(x: 0.1, y: 0.9 - 0.05 * CGFloat(index), width: 0.8, height: 0.03))
        }
    }

    @Test func 見出し語と同じ行の値を取り出す() {
        let fields = CardParser.parse(stacked(["エチオピア ゲデブ", "農園：ゲデブ"]))

        #expect(fields.farm == "ゲデブ")
    }

    @Test(arguments: ["農園:ゲデブ", "農園 ゲデブ", "農園\u{3000}ゲデブ", "農園 ： ゲデブ "])
    func 見出し語のあとの区切りはコロンと空白(line: String) {
        #expect(CardParser.parse(stacked([line])).farm == "ゲデブ")
    }

    @Test(arguments: ["Farm: Gedeb", "FARM Gedeb", "farm：Gedeb"])
    func 英語の見出し語は大文字小文字を区別しない(line: String) {
        #expect(CardParser.parse(stacked([line])).farm == "Gedeb")
    }

    @Test(arguments: ["農園", "農園：", "Farm:"])
    func 見出し語だけの行なら次の行を値にする(label: String) {
        #expect(CardParser.parse(stacked([label, "ゲデブ"])).farm == "ゲデブ")
    }

    @Test func 次の行も見出し語なら値にしない() {
        let fields = CardParser.parse(stacked(["農園", "精製方法", "ナチュラル"]))

        #expect(fields.farm == nil)
        #expect(fields.process == "ナチュラル")
    }

    @Test func 同じ項目が何度も出たら最初の値を使う() {
        #expect(CardParser.parse(stacked(["農園：ゲデブ", "Farm: Other"])).farm == "ゲデブ")
    }

    @Test(arguments: ["Farmhouse Blend", "農園主のおすすめ"])
    func 見出し語のすぐあとに文字が続くものは見出し語と見なさない(line: String) {
        #expect(CardParser.parse(stacked([line, "ゲデブ"])).farm == nil)
    }

    @Test func 日本語のカードから7項目を読む() {
        let fields = CardParser.parse(stacked([
            "エチオピア イルガチェフェ ゲデブ",
            "生産国：エチオピア",
            "地域：イルガチェフェ",
            "農園：ゲデブ",
            "品種：在来種",
            "精製方法：ナチュラル",
            "標高：1,900–2,100m",
            "フレーバー：ブルーベリー、ジャスミン",
        ]))

        #expect(fields == CardFields(
            origin: "エチオピア", region: "イルガチェフェ", farm: "ゲデブ", variety: "在来種",
            process: "ナチュラル", altitude: "1,900–2,100m", tastingNotes: "ブルーベリー、ジャスミン"
        ))
    }

    @Test func 英語のカードから7項目を読む() {
        let fields = CardParser.parse(stacked([
            "Country: Kenya",
            "Region: Nyeri",
            "Producer: Gichathaini Factory",
            "Varietal: SL28, SL34",
            "Process: Washed",
            "Altitude: 1,700m",
            "Tasting Notes: Blackcurrant, Grapefruit",
        ]))

        #expect(fields == CardFields(
            origin: "Kenya", region: "Nyeri", farm: "Gichathaini Factory", variety: "SL28, SL34",
            process: "Washed", altitude: "1,700m", tastingNotes: "Blackcurrant, Grapefruit"
        ))
    }

    @Test(arguments: [
        ("焙煎度：浅煎り", Roast.light),
        ("焙煎度：中煎り", .medium),
        ("焙煎度：中深煎り（フルシティ）", .mediumDark),
        ("焙煎：深煎り", .dark),
        ("Roast: Light", .light),
        ("Roast Level: Medium", .medium),
        ("ROAST: Medium-Dark", .mediumDark),
        ("Roast: Medium Dark", .mediumDark),
        ("Roast: Dark", .dark),
    ])
    func 焙煎度はアプリの4段階に読み替える(line: String, expected: Roast) {
        #expect(CardParser.parse(stacked([line])).roast == expected)
    }

    @Test(arguments: ["焙煎度：シティロースト", "Roast: 2024.09.01"])
    func 焙煎度が読み替えられなければnil(line: String) {
        #expect(CardParser.parse(stacked([line])).roast == nil)
    }
}
