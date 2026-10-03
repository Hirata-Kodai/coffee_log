import Foundation
import SwiftData

/// 一覧の検索欄の条件
enum RecordSearch {
    /// 豆の名前の部分一致（大文字小文字を区別しない）。検索欄が空欄なら nil（絞り込まない）
    static func predicate(matching text: String) -> Predicate<CoffeeRecord>? {
        guard let keyword = text.nilIfBlank else { return nil }
        return #Predicate<CoffeeRecord> { $0.name.localizedStandardContains(keyword) }
    }
}
