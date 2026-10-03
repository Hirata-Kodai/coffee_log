import Foundation
import Testing
@testable import CoffeeLog

// TODO（詳細画面の基本情報）
// - [x] 未入力の項目は出さない
// - [ ] 購入形態・焙煎度は日本語の名前で出す
// - [ ] 価格は ¥ と 3 桁区切りで出す
// - [ ] 価格と容量があれば 1 行にまとめる
// - [ ] 容量だけなら容量の行にする
// - [ ] 生産国・品種を出す
// - [ ] 並びは 購入形態 → 焙煎度 → 価格 → 生産国 → 品種
@MainActor
struct RecordDetailTests {
    private func record() -> CoffeeRecord {
        CoffeeRecord(name: "ケニア AB", rating: 4, date: .now, createdAt: .now)
    }

    @Test func 未入力の項目は出さない() {
        #expect(RecordDetail.infoRows(for: record()).isEmpty)
    }
}
