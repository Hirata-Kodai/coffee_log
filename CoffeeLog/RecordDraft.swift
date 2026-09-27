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
    /// 価格（円）の入力欄の文字列。空欄は未入力
    var priceText: String = ""

    var canSave: Bool {
        hasName && hasValidRating && hasValidPrice
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
        record.price = price
        return record
    }

    /// 空欄なら nil
    private var price: Int? {
        priceText.nilIfBlank.flatMap { Int($0) }
    }

    private var hasName: Bool {
        name.nilIfBlank != nil
    }

    private var hasValidRating: Bool {
        guard let rating else { return false }
        return Self.ratingRange.contains(rating)
    }

    /// 空欄は有効。入力があれば 0 以上の整数として読めること
    private var hasValidPrice: Bool {
        guard priceText.nilIfBlank != nil else { return true }
        guard let price else { return false }
        return price >= 0
    }
}
