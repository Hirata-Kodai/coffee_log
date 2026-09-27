import Testing
@testable import CoffeeLog

// TODO（保存可否の判定）
// - [x] 名称が空白だけなら保存できない
// - [x] 名称が空なら保存できない
// - [x] 評価が未選択なら保存できない
// - [x] 評価が 1〜5 の範囲外なら保存できない
// - [x] 名称と評価（1〜5）があれば保存できる
// - [x] 価格が 0 以上の整数として読めなければ保存できない
struct RecordDraftTests {
    @Test(arguments: ["", "   ", "\u{3000}", "\n"])
    func 名称が空か空白だけなら保存できない(name: String) {
        let draft = RecordDraft(name: name, rating: 3)
        #expect(draft.canSave == false)
    }

    @Test func 評価が未選択なら保存できない() {
        let draft = RecordDraft(name: "ケニア AB", rating: nil)
        #expect(draft.canSave == false)
    }

    @Test(arguments: [0, 6])
    func 評価が範囲外なら保存できない(rating: Int) {
        let draft = RecordDraft(name: "ケニア AB", rating: rating)
        #expect(draft.canSave == false)
    }

    @Test(arguments: [1, 5])
    func 名称と評価があれば保存できる(rating: Int) {
        let draft = RecordDraft(name: "ケニア AB", rating: rating)
        #expect(draft.canSave == true)
    }

    @Test(arguments: ["abc", "-100", "1,200", "12.5", "１２００"])
    func 価格が0以上の整数として読めなければ保存できない(priceText: String) {
        var draft = RecordDraft(name: "ケニア AB", rating: 3)
        draft.priceText = priceText
        #expect(draft.canSave == false)
    }
}
