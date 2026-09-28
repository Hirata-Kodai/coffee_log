import Foundation

/// 新しい順の一覧で、同じ日の記録をまとめたもの
struct DaySection {
    /// calendar でのその日の 0 時
    let day: Date
    let records: [CoffeeRecord]

    /// 並んでいる順を保ったまま、日が変わるたびに区切る。records は新しい順に並べて渡す
    static func group(_ records: [CoffeeRecord], calendar: Calendar) -> [DaySection] {
        var sections: [DaySection] = []
        for record in records {
            let day = calendar.startOfDay(for: record.date)
            if let last = sections.last, last.day == day {
                sections[sections.count - 1] = DaySection(day: day, records: last.records + [record])
            } else {
                sections.append(DaySection(day: day, records: [record]))
            }
        }
        return sections
    }
}
