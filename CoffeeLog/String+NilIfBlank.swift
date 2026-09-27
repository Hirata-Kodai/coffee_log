import Foundation

extension String {
    /// 任意の入力欄の値を保存用にそろえる。前後の空白を取り除き、空欄は nil にする。
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
