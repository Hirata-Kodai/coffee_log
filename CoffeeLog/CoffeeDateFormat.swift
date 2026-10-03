import Foundation

/// 画面に出す日付の形式。端末の言語設定によらず数字と英語表記で固定する
enum CoffeeDateFormat {
    /// 一覧の行: 09.25
    static func short(_ date: Date, calendar: Calendar = .current) -> String {
        format(date, "MM.dd", calendar: calendar)
    }

    /// 日付見出し・詳細: 2026.09.25 FRI
    static func long(_ date: Date, calendar: Calendar = .current) -> String {
        format(date, "yyyy.MM.dd EEE", calendar: calendar).uppercased()
    }

    private static func format(_ date: Date, _ template: String, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = template
        return formatter.string(from: date)
    }
}
