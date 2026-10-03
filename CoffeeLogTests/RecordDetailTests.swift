import Foundation
import Testing
@testable import CoffeeLog

// TODO（詳細画面の基本情報）
// - [x] 未入力の項目は出さない
// - [x] 購入形態・焙煎度は日本語の名前で出す
// - [x] 価格は ¥ と 3 桁区切りで出す
// - [x] 価格と容量があれば 1 行にまとめる
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

    @Test func 購入形態と焙煎度は日本語の名前で出す() {
        let record = record()
        record.purchaseType = .bean
        record.roast = .mediumDark

        #expect(RecordDetail.infoRows(for: record) == [
            .init(label: "購入形態", value: "豆"),
            .init(label: "焙煎度", value: "中深煎り"),
        ])
    }

    @Test func 価格はyenと3桁区切りで出す() {
        let record = record()
        record.price = 1800

        #expect(RecordDetail.infoRows(for: record) == [.init(label: "価格", value: "¥1,800")])
    }

    @Test func 価格と容量があれば1行にまとめる() {
        let record = record()
        record.price = 1800
        record.volume = "200g"

        #expect(RecordDetail.infoRows(for: record) == [.init(label: "価格", value: "¥1,800 / 200g")])
    }
}
