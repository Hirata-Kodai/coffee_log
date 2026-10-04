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
// - [ ] 8 項目それぞれの見出し語を読む
// - [ ] 焙煎度はアプリの 4 段階に読み替え、読み替えられなければ nil
struct CardParserTests {
    @Test func 見出し語と同じ行の値を取り出す() {
        let fields = CardParser.parse(["エチオピア ゲデブ", "農園：ゲデブ"])

        #expect(fields.farm == "ゲデブ")
    }

    @Test(arguments: ["農園:ゲデブ", "農園 ゲデブ", "農園\u{3000}ゲデブ", "農園 ： ゲデブ "])
    func 見出し語のあとの区切りはコロンと空白(line: String) {
        #expect(CardParser.parse([line]).farm == "ゲデブ")
    }

    @Test(arguments: ["Farm: Gedeb", "FARM Gedeb", "farm：Gedeb"])
    func 英語の見出し語は大文字小文字を区別しない(line: String) {
        #expect(CardParser.parse([line]).farm == "Gedeb")
    }

    @Test(arguments: ["農園", "農園：", "Farm:"])
    func 見出し語だけの行なら次の行を値にする(label: String) {
        #expect(CardParser.parse([label, "ゲデブ"]).farm == "ゲデブ")
    }

    @Test func 次の行も見出し語なら値にしない() {
        let fields = CardParser.parse(["農園", "精製方法", "ナチュラル"])

        #expect(fields.farm == nil)
        #expect(fields.process == "ナチュラル")
    }

    @Test func 同じ項目が何度も出たら最初の値を使う() {
        #expect(CardParser.parse(["農園：ゲデブ", "Farm: Other"]).farm == "ゲデブ")
    }

    @Test(arguments: ["Farmhouse Blend", "農園主のおすすめ"])
    func 見出し語のすぐあとに文字が続くものは見出し語と見なさない(line: String) {
        #expect(CardParser.parse([line, "ゲデブ"]).farm == nil)
    }
}
