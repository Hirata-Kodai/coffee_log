import Foundation
import Testing
@testable import CoffeeLog

// TODO（RecordDraft → CoffeeRecord の変換）
// - [x] 名称・評価・作成日時を持つ記録を作れる
// - [x] 名称は前後の空白を除いて保存する
// - [x] 日付はその日の 0 時にそろえる
// - [ ] 任意の文字列項目（店・容量・生産国・品種・メモ）は前後の空白を除き、空欄は nil にする
// - [ ] 価格は空欄なら nil、数字なら Int にする
// - [ ] 購入形態・焙煎度・写真・味 6 軸はそのまま引き継ぐ
// - [ ] 保存できない下書きからは作れない
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
}
