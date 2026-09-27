import Testing
@testable import CoffeeLog

// テスト基盤が動くことだけを確かめる仮のテスト。最初の本物のテストを書いたら削除する。
struct SmokeTests {
    @Test func テスト基盤が動く() {
        #expect(true)
    }
}
