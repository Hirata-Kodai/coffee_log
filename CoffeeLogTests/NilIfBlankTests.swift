import Testing
@testable import CoffeeLog

// TODO（任意の文字列の空欄を nil にそろえる）
// - [x] 空文字は nil になる
// - [ ] 文字があればそのまま返す
// - [ ] 空白だけ（半角・全角・改行）は nil になる
// - [ ] 前後の空白は取り除く
// - [ ] 途中の空白は残す
struct NilIfBlankTests {
    @Test func 空文字はnilになる() {
        #expect("".nilIfBlank == nil)
    }
}
