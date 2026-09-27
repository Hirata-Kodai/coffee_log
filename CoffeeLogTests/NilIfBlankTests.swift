import Testing
@testable import CoffeeLog

// TODO（任意の文字列の空欄を nil にそろえる）
// - [x] 空文字は nil になる
// - [x] 文字があればそのまま返す
// - [x] 空白だけ（半角・全角・改行）は nil になる
// - [x] 前後の空白は取り除く
// - [x] 途中の空白は残す
struct NilIfBlankTests {
    @Test func 空文字はnilになる() {
        #expect("".nilIfBlank == nil)
    }

    @Test func 文字があればそのまま返す() {
        #expect("村上コーヒー".nilIfBlank == "村上コーヒー")
    }

    @Test(arguments: ["   ", "\u{3000}", "\n"])
    func 空白だけならnilになる(value: String) {
        #expect(value.nilIfBlank == nil)
    }

    @Test func 前後の空白は取り除く() {
        #expect(" 村上コーヒー\u{3000}".nilIfBlank == "村上コーヒー")
    }

    @Test func 途中の空白は残す() {
        #expect(" ケニア AB ".nilIfBlank == "ケニア AB")
    }
}
