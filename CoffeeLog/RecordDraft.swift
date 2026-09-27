import Foundation

/// 入力画面で編集中の記録。保存できるかどうかを判定し、保存用の CoffeeRecord を作る。
struct RecordDraft {
    static let ratingRange = 1...5

    var name: String = ""
    /// 未選択は nil
    var rating: Int? = nil
    var date: Date = .now

    // 任意の文字列項目。空欄は "" で持ち、保存時に nil にそろえる
    var shop: String = ""
    var volume: String = ""
    var origin: String = ""
    var variety: String = ""
    var memo: String = ""

    var canSave: Bool {
        hasName && hasValidRating
    }

    /// 保存できない下書きなら nil。now は作成日時になる。日付は calendar でその日の 0 時にそろえる
    func makeRecord(now: Date, calendar: Calendar = .current) -> CoffeeRecord? {
        guard let name = name.nilIfBlank, let rating else { return nil }
        let record = CoffeeRecord(name: name, rating: rating, date: calendar.startOfDay(for: date), createdAt: now)
        record.shop = shop.nilIfBlank
        record.volume = volume.nilIfBlank
        record.origin = origin.nilIfBlank
        record.variety = variety.nilIfBlank
        record.memo = memo.nilIfBlank
        return record
    }

    private var hasName: Bool {
        name.nilIfBlank != nil
    }

    private var hasValidRating: Bool {
        guard let rating else { return false }
        return Self.ratingRange.contains(rating)
    }
}
