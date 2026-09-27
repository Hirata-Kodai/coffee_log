import Foundation

/// 入力画面で編集中の記録。保存できるかどうかを判定する。
struct RecordDraft {
    static let ratingRange = 1...5

    var name: String = ""
    /// 未選択は nil
    var rating: Int? = nil

    var canSave: Bool {
        hasName && hasValidRating
    }

    private var hasName: Bool {
        name.nilIfBlank != nil
    }

    private var hasValidRating: Bool {
        guard let rating else { return false }
        return Self.ratingRange.contains(rating)
    }
}
