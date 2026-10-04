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
// - [x] v2 の項目を足した並びは 購入形態 → 焙煎度 → 価格 → 生産国 → 地域 → 農園 → 品種 → 精製方法 → 標高（テイスティングノートは出さない）
//
// TODO（詳細画面の味）
// - [x] 味が全部未入力ならチャートを出さない
// - [x] 香り → 酸味 → 甘さ → コク → 後味 → 苦味 の順で値を返し、未入力は nil
// - [x] 要約は「香り 5 · 酸味 4 …（5段階）」で、未入力は「-」
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

    @Test func v2の項目を足した並びと値() {
        let record = record()
        record.altitude = "1,700m"
        record.process = "ウォッシュト"
        record.variety = "SL28"
        record.farm = "ギチャサイニ農園"
        record.region = "ニエリ"
        record.origin = "ケニア"
        record.tastingNotes = "ブラックカラント"

        #expect(RecordDetail.infoRows(for: record) == [
            .init(label: "生産国", value: "ケニア"),
            .init(label: "地域", value: "ニエリ"),
            .init(label: "農園", value: "ギチャサイニ農園"),
            .init(label: "品種", value: "SL28"),
            .init(label: "精製方法", value: "ウォッシュト"),
            .init(label: "標高", value: "1,700m"),
        ])
    }

    @Test func 味が全部未入力ならチャートを出さない() {
        #expect(RecordDetail.taste(for: record()) == nil)
    }

    @Test func 味は香りから苦味の順で値を返し未入力はnil() throws {
        let record = record()
        record.aroma = 5
        record.sweetness = 4
        record.bitterness = 1

        let taste = try #require(RecordDetail.taste(for: record))

        #expect(taste.values.map(\.name) == ["香り", "酸味", "甘さ", "コク", "後味", "苦味"])
        #expect(taste.values.map(\.value) == [5, nil, 4, nil, nil, 1])
    }

    @Test func 味の要約は軸と値を並べ未入力はハイフン() throws {
        let record = record()
        record.aroma = 5
        record.acidity = 4
        record.bitterness = 1

        let taste = try #require(RecordDetail.taste(for: record))

        #expect(taste.summary == "香り 5 · 酸味 4 · 甘さ - · コク - · 後味 - · 苦味 1（5段階）")
    }
}
