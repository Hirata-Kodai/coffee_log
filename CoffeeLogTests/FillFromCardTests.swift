import Testing
@testable import CoffeeLog

// TODO（カードから読み取った値を下書きに入れる）
// - [x] 空欄に読み取った値を入れる
// - [ ] 入力済みの欄は変えない（空白だけの欄は空欄と見なす）
// - [ ] 焙煎度は未選択のときだけ入れる
// - [ ] 入れた項目の数を返す
struct FillFromCardTests {
    private let card = CardFields(
        origin: "エチオピア", region: "イルガチェフェ", farm: "ゲデブ", variety: "在来種",
        process: "ナチュラル", altitude: "1,900m", tastingNotes: "ブルーベリー", roast: .light
    )

    @Test func 空欄に読み取った値を入れる() {
        var draft = RecordDraft()

        draft.fillBlanks(from: card)

        #expect([draft.origin, draft.region, draft.farm, draft.variety, draft.process, draft.altitude, draft.tastingNotes]
                == ["エチオピア", "イルガチェフェ", "ゲデブ", "在来種", "ナチュラル", "1,900m", "ブルーベリー"])
        #expect(draft.roast == .light)
    }
}
