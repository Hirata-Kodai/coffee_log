import Foundation

/// 入力画面で編集中の記録。保存できるかどうかを判定する。
struct RecordDraft {
    var name: String = ""
    /// 未選択は nil
    var rating: Int? = nil

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
