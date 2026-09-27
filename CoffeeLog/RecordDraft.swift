import Foundation

/// 入力画面で編集中の記録。保存できるかどうかを判定し、保存用の CoffeeRecord を作る。
struct RecordDraft {
    static let ratingRange = 1...5

    var name: String = ""
    /// 未選択は nil
    var rating: Int? = nil
    var date: Date = .now

    var canSave: Bool {
        hasName && hasValidRating
    }

    /// 保存できない下書きなら nil。now は作成日時になる
    func makeRecord(now: Date) -> CoffeeRecord? {
        guard let name = name.nilIfBlank, let rating else { return nil }
        return CoffeeRecord(name: name, rating: rating, date: date, createdAt: now)
    }

    private var hasName: Bool {
        name.nilIfBlank != nil
    }

    private var hasValidRating: Bool {
        guard let rating else { return false }
        return Self.ratingRange.contains(rating)
    }
}
