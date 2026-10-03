import Foundation
import SwiftData

/// 一覧の検索欄の条件
enum RecordSearch {
    static func predicate(matching text: String) -> Predicate<CoffeeRecord>? {
        let keyword = text.nilIfBlank ?? ""
        return #Predicate<CoffeeRecord> { $0.name.localizedStandardContains(keyword) }
    }
}
