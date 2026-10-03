import Foundation
import Testing
@testable import CoffeeLog

// TODO（日付の表示形式）
// - [x] 一覧の行は「月.日」（09.25）
// - [ ] 日付見出しは「年.月.日 曜日」で曜日は英語の大文字 3 文字（2026.09.25 FRI）
struct CoffeeDateFormatTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }()
    // 2026-09-25 金曜の 0 時（東京）。UTC では 24 日になる
    private let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 25))!

    @Test func 一覧の行は月と日() {
        #expect(CoffeeDateFormat.short(date, calendar: Self.calendar) == "09.25")
    }
}
