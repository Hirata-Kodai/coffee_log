import Foundation
import Testing
@testable import CoffeeLog

// TODO（詳細画面の基本情報）
// - [x] 未入力の項目は出さない
// - [x] 購入形態・焙煎度は日本語の名前で出す
// - [x] 価格は ¥ と 3 桁区切りで出す
// - [x] 価格と容量があれば 1 行にまとめる
// - [x] 容量だけなら容量の行にする
// - [x] 生産国・品種を出す
// - [x] 並びは 購入形態 → 焙煎度 → 価格 → 生産国 → 品種
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

    @Test func 容量だけなら容量の行にする() {
        let record = record()
        record.volume = "R"

        #expect(RecordDetail.infoRows(for: record) == [.init(label: "容量", value: "R")])
    }

    @Test func 生産国と品種を出す() {
        let record = record()
        record.origin = "ケニア"
        record.variety = "SL28"

        #expect(RecordDetail.infoRows(for: record) == [
            .init(label: "生産国", value: "ケニア"),
            .init(label: "品種", value: "SL28"),
        ])
    }

    @Test func 並びは購入形態と焙煎度と価格と生産国と品種の順() {
        let record = record()
        record.variety = "SL28"
        record.origin = "ケニア"
        record.price = 1800
        record.roast = .light
        record.purchaseType = .cafe

        #expect(RecordDetail.infoRows(for: record).map(\.label) == ["購入形態", "焙煎度", "価格", "生産国", "品種"])
    }
}
