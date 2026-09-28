import Foundation

/// 新しい順の一覧で、同じ日の記録をまとめたもの
struct DaySection {
    let day: Date
    let records: [CoffeeRecord]

    static func group(_ records: [CoffeeRecord], calendar: Calendar) -> [DaySection] {
        var sections: [DaySection] = []
        for record in records {
            if let last = sections.last, last.day == record.date {
                sections[sections.count - 1] = DaySection(day: last.day, records: last.records + [record])
            } else {
                sections.append(DaySection(day: record.date, records: [record]))
            }
        }
        return sections
    }
}
