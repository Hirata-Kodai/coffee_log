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
//
// TODO（文字のかたまりの位置から値を探す。日英 2 列のカード対応）
// - [x] 右隣が見出しなら値にせず、真下のかたまりを値にする
// - [x] 見出しから離れた下のかたまりは値にしない
// - [x] 見出しの右隣のかたまりを値にする（表形式のカード）
// - [x] 日本語と英語の値があれば日本語を優先する
// - [x] 「生豆生産国」「精選」を見出し語に足す
// - [x] 中間の焙煎度（Medium Light、ミディアムライト）は入れない。カタカナの焙煎度も読む
// - [ ] 実機で読んだ小川珈琲のカードから項目を取り出す
struct CardParserTests {
    /// 位置を指定した文字のかたまり（位置は左下が原点の割合）
    private func text(_ string: String, x: CGFloat, y: CGFloat, width: CGFloat = 0.15, height: CGFloat = 0.02) -> RecognizedText {
        RecognizedText(text: string, box: CGRect(x: x, y: y, width: width, height: height))
    }

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

    @Test func 右隣が見出しなら値にせず真下のかたまりを値にする() {
        // 左に英語、右に日本語。どちらも見出しの下に値がある
        let fields = CardParser.parse([
            text("Country", x: 0.29, y: 0.665, width: 0.075, height: 0.015),
            text("Guatemala", x: 0.29, y: 0.639, width: 0.114, height: 0.017),
            text("生豆生産国", x: 0.644, y: 0.666, width: 0.100, height: 0.019),
            text("Region", x: 0.29, y: 0.610, width: 0.067, height: 0.015),
            text("地域", x: 0.703, y: 0.615, width: 0.042, height: 0.019),
        ])

        #expect(fields.origin == "Guatemala")
    }

    @Test func 見出しから離れた下のかたまりは値にしない() {
        let fields = CardParser.parse([
            text("農園", x: 0.1, y: 0.80, height: 0.02),
            text("小川珈琲", x: 0.1, y: 0.50, height: 0.02),
        ])

        #expect(fields.farm == nil)
    }

    @Test func 見出しの右隣のかたまりを値にする() {
        // 見出しの列と値の列が分かれた表形式
        let fields = CardParser.parse([
            text("農園", x: 0.065, y: 0.575, width: 0.082, height: 0.040),
            text("ゲデブ", x: 0.350, y: 0.575, width: 0.121, height: 0.039),
            text("品種", x: 0.063, y: 0.479, width: 0.090, height: 0.050),
            text("在来種", x: 0.350, y: 0.487, width: 0.121, height: 0.037),
        ])

        #expect(fields.farm == "ゲデブ")
        #expect(fields.variety == "在来種")
    }

    @Test func 生豆生産国と精選を見出し語として読む() {
        let fields = CardParser.parse(stacked(["生豆生産国：グアテマラ", "精選：ウォッシュド"]))

        #expect(fields.origin == "グアテマラ")
        #expect(fields.process == "ウォッシュド")
    }

    @Test func 日本語と英語の値があれば日本語を優先する() {
        // 左に英語、右に日本語。日本語の見出しをわずかに下にして、上から順に見ると英語が先に出るようにする
        let fields = CardParser.parse([
            text("Country", x: 0.29, y: 0.665, width: 0.075, height: 0.015),
            text("Guatemala", x: 0.29, y: 0.639, width: 0.114, height: 0.017),
            text("生豆生産国", x: 0.644, y: 0.660, width: 0.100, height: 0.019),
            text("グアテマラ", x: 0.631, y: 0.636, width: 0.111, height: 0.021),
            text("Process", x: 0.29, y: 0.408, width: 0.075, height: 0.013),
            text("Washed", x: 0.29, y: 0.383, width: 0.083, height: 0.017),
        ])

        #expect(fields.origin == "グアテマラ")
        // 日本語の値がなければ英語
        #expect(fields.process == "Washed")
    }

    @Test(arguments: [
        ("焙煎度：ライトロースト", Roast.light),
        ("焙煎度：ミディアムロースト", .medium),
        ("焙煎度：ミディアムダーク", .mediumDark),
        ("焙煎度：ダークロースト", .dark),
    ])
    func カタカナの焙煎度も読む(line: String, expected: Roast) {
        #expect(CardParser.parse(stacked([line])).roast == expected)
    }

    @Test(arguments: ["Roast Level: Medium Light", "焙煎度：ミディアムライト", "焙煎度：中浅煎り"])
    func 中間の焙煎度は入れない(line: String) {
        #expect(CardParser.parse(stacked([line])).roast == nil)
    }
}
