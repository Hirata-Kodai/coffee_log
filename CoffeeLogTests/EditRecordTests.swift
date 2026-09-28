import Foundation
import Testing
@testable import CoffeeLog

// TODO（記録の編集）
// - [x] 記録から下書きを作ると全項目が入る（未入力の文字列は空欄、価格は文字列）
// - [x] 下書きを既存の記録に反映すると全項目が入れ替わる（空欄は nil、名称の空白除去、日付は 0 時）
// - [ ] 反映しても作成日時は変わらない
// - [ ] 保存できない下書きは反映せず、記録は元のまま
@MainActor
struct EditRecordTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }()
    private let day = calendar.date(from: DateComponents(year: 2026, month: 9, day: 25))!
    private let createdAt = Date(timeIntervalSince1970: 1_790_000_100)

    /// 全項目が入った記録
    private func filledRecord() -> CoffeeRecord {
        let record = CoffeeRecord(name: "ケニア AB", rating: 4, date: day, createdAt: createdAt)
        record.shop = "村上コーヒー"
        record.purchaseType = .bean
        record.roast = .mediumDark
        record.price = 1200
        record.volume = "100g"
        record.photo = Data([0x01, 0x02])
        record.aroma = 4
        record.acidity = 3
        record.sweetness = 2
        record.body = 5
        record.aftertaste = 4
        record.bitterness = 1
        record.origin = "ケニア"
        record.variety = "SL28"
        record.memo = "ベリーの香り"
        return record
    }

    @Test func 記録から下書きを作ると全項目が入る() {
        let draft = RecordDraft(record: filledRecord())

        #expect(draft.name == "ケニア AB")
        #expect(draft.rating == 4)
        #expect(draft.date == day)
        #expect(draft.shop == "村上コーヒー")
        #expect(draft.purchaseType == .bean)
        #expect(draft.roast == .mediumDark)
        #expect(draft.priceText == "1200")
        #expect(draft.volume == "100g")
        #expect(draft.photo == Data([0x01, 0x02]))
        #expect([draft.aroma, draft.acidity, draft.sweetness,
                 draft.body, draft.aftertaste, draft.bitterness] == [4, 3, 2, 5, 4, 1])
        #expect(draft.origin == "ケニア")
        #expect(draft.variety == "SL28")
        #expect(draft.memo == "ベリーの香り")
    }

    @Test func 記録の未入力の項目は下書きでは空欄になる() {
        let record = CoffeeRecord(name: "ケニア AB", rating: 4, date: day, createdAt: createdAt)

        let draft = RecordDraft(record: record)

        #expect([draft.shop, draft.volume, draft.origin, draft.variety, draft.memo, draft.priceText]
                == ["", "", "", "", "", ""])
        #expect(draft.purchaseType == nil)
        #expect(draft.photo == nil)
        #expect(draft.aroma == nil)
    }

    @Test func 下書きを既存の記録に反映すると全項目が入れ替わる() throws {
        let record = filledRecord()
        let evening = try #require(Self.calendar.date(from: DateComponents(year: 2026, month: 9, day: 26, hour: 21)))
        var draft = RecordDraft(name: " エチオピア ", rating: 5, date: evening)
        draft.shop = " "
        draft.purchaseType = .cafe
        draft.priceText = "650"
        draft.aroma = 5

        let applied = draft.apply(to: record, calendar: Self.calendar)

        #expect(applied)
        #expect(record.name == "エチオピア")
        #expect(record.rating == 5)
        #expect(record.date == Self.calendar.date(from: DateComponents(year: 2026, month: 9, day: 26)))
        #expect(record.shop == nil)
        #expect(record.purchaseType == .cafe)
        #expect(record.roast == nil)
        #expect(record.price == 650)
        #expect(record.volume == nil)
        #expect(record.photo == nil)
        #expect([record.aroma, record.acidity, record.sweetness,
                 record.body, record.aftertaste, record.bitterness] == [5, nil, nil, nil, nil, nil])
        #expect(record.origin == nil)
        #expect(record.variety == nil)
        #expect(record.memo == nil)
    }
}
