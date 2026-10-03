import Foundation
import Testing
@testable import CoffeeLog

// TODO（RecordDraft → CoffeeRecord の変換）
// - [x] 名称・評価・作成日時を持つ記録を作れる
// - [x] 名称は前後の空白を除いて保存する
// - [x] 日付はその日の 0 時にそろえる
// - [x] 任意の文字列項目（店・生産国・品種・メモ）は前後の空白を除き、空欄は nil にする
// - [x] 容量は数字に g を付けて保存し、空欄は nil にする
// - [x] 価格は空欄なら nil、数字なら Int にする
// - [x] 購入形態・焙煎度・写真・味 6 軸はそのまま引き継ぐ
// - [x] 保存できない下書きからは作れない
@MainActor
struct MakeRecordTests {
    private let now = Date(timeIntervalSince1970: 1_790_000_100)

    @Test func 名称と評価と作成日時を持つ記録を作れる() throws {
        let draft = RecordDraft(name: "ケニア AB", rating: 4)

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.name == "ケニア AB")
        #expect(record.rating == 4)
        #expect(record.createdAt == now)
    }

    @Test func 名称は前後の空白を除いて保存する() throws {
        let draft = RecordDraft(name: "\u{3000} ケニア AB \n", rating: 4)

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.name == "ケニア AB")
    }

    @Test func 日付はその日の0時にそろえる() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let evening = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 25, hour: 21, minute: 30)))
        let midnight = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 25)))
        let draft = RecordDraft(name: "ケニア AB", rating: 4, date: evening)

        let record = try #require(draft.makeRecord(now: now, calendar: calendar))

        #expect(record.date == midnight)
    }

    @Test func 任意の文字列項目は前後の空白を除いて保存する() throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.shop = " 村上コーヒー "
        draft.origin = "\u{3000}ケニア"
        draft.variety = " SL28 "
        draft.memo = " ベリーの香り\n後味が長い \n"

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.shop == "村上コーヒー")
        #expect(record.origin == "ケニア")
        #expect(record.variety == "SL28")
        #expect(record.memo == "ベリーの香り\n後味が長い")
    }

    @Test func 任意の文字列項目は空欄ならnilにする() throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.shop = ""
        draft.origin = "\u{3000}"
        draft.variety = "\n"
        draft.memo = " \n "

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.shop == nil)
        #expect(record.origin == nil)
        #expect(record.variety == nil)
        #expect(record.memo == nil)
    }

    @Test(arguments: [("1200", 1200), (" 1200 ", 1200), ("0", 0)])
    func 価格は数字ならIntにして保存する(priceText: String, expected: Int) throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.priceText = priceText

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.price == expected)
    }

    @Test(arguments: ["", " "])
    func 価格は空欄ならnilにする(priceText: String) throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.priceText = priceText

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.price == nil)
    }

    @Test func 購入形態と焙煎度と写真と味6軸はそのまま引き継ぐ() throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.purchaseType = .bean
        draft.roast = .mediumDark
        draft.photo = Data([0x01, 0x02])
        draft.aroma = 4
        draft.acidity = 3
        draft.sweetness = 2
        draft.body = 5
        draft.aftertaste = 1
        draft.bitterness = nil

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.purchaseType == .bean)
        #expect(record.roast == .mediumDark)
        #expect(record.photo == Data([0x01, 0x02]))
        #expect([record.aroma, record.acidity, record.sweetness,
                 record.body, record.aftertaste, record.bitterness] == [4, 3, 2, 5, 1, nil])
    }

    @Test(arguments: [
        RecordDraft(name: " ", rating: 4),
        RecordDraft(name: "ケニア AB", rating: nil),
        RecordDraft(name: "ケニア AB", rating: 6),
        RecordDraft(name: "ケニア AB", rating: 4, priceText: "-100"),
    ])
    func 保存できない下書きからは作れない(draft: RecordDraft) {
        #expect(draft.makeRecord(now: now) == nil)
    }

    @Test(arguments: [("200", "200g"), (" 200 ", "200g")])
    func 容量は数字にgを付けて保存する(volume: String, expected: String) throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.volume = volume

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.volume == expected)
    }

    @Test(arguments: ["", " "])
    func 容量は空欄ならnilにする(volume: String) throws {
        var draft = RecordDraft(name: "ケニア AB", rating: 4)
        draft.volume = volume

        let record = try #require(draft.makeRecord(now: now))

        #expect(record.volume == nil)
    }
}
