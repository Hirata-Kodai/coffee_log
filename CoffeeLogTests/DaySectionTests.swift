import Foundation
import Testing
@testable import CoffeeLog

// TODO（新しい順の一覧を日付ごとにまとめる）
// - [x] 記録がなければまとまりもない
// - [x] 同じ日の記録は 1 つのまとまりにし、並びを保つ
// - [ ] 日が変わるたびに新しいまとまりを作り、並びを保つ
// - [ ] 日の区切りは calendar のタイムゾーンで決め、まとまりの日付はその日の 0 時
@MainActor
struct DaySectionTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }()

    /// 2026 年 9 月 day 日 hour 時（東京）
    private func date(day: Int, hour: Int = 0) -> Date {
        Self.calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour))!
    }

    private func record(_ name: String, _ date: Date) -> CoffeeRecord {
        CoffeeRecord(name: name, rating: 3, date: date, createdAt: date)
    }

    @Test func 記録がなければまとまりもない() {
        #expect(DaySection.group([], calendar: Self.calendar).isEmpty)
    }

    @Test func 同じ日の記録は1つのまとまりにし並びを保つ() throws {
        let sections = DaySection.group([
            record("A", date(day: 25)),
            record("B", date(day: 25)),
        ], calendar: Self.calendar)

        let section = try #require(sections.first)
        #expect(sections.count == 1)
        #expect(section.day == date(day: 25))
        #expect(section.records.map(\.name) == ["A", "B"])
    }
}
