import Foundation

/// 新しい順の一覧で、同じ日の記録をまとめたもの
struct DaySection {
    let day: Date
    let records: [CoffeeRecord]

    static func group(_ records: [CoffeeRecord], calendar: Calendar) -> [DaySection] {
        guard let first = records.first else { return [] }
        return [DaySection(day: first.date, records: records)]
    }
}
