import Testing
@testable import CoffeeLog

// TODO（保存可否の判定）
// - [x] 名称が空白だけなら保存できない
// - [ ] 名称が空なら保存できない
// - [ ] 評価が未選択なら保存できない
// - [ ] 評価が 1〜5 の範囲外なら保存できない
// - [ ] 名称と評価（1〜5）があれば保存できる
struct RecordDraftTests {
    @Test func 名称が空白だけなら保存できない() {
        let draft = RecordDraft(name: "   ", rating: 3)
        #expect(draft.canSave == false)
    }
}
