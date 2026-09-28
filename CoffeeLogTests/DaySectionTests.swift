import Foundation
import Testing
@testable import CoffeeLog

// TODO（新しい順の一覧を日付ごとにまとめる）
// - [x] 記録がなければまとまりもない
// - [ ] 同じ日の記録は 1 つのまとまりにし、並びを保つ
// - [ ] 日が変わるたびに新しいまとまりを作り、並びを保つ
// - [ ] 日の区切りは calendar のタイムゾーンで決め、まとまりの日付はその日の 0 時
@MainActor
struct DaySectionTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }()

    @Test func 記録がなければまとまりもない() {
        #expect(DaySection.group([], calendar: Self.calendar).isEmpty)
    }
}
