import Foundation

/// 一覧の並び順
enum RecordSortOrder: String {
    /// 評価の高い順（比べる）
    case rating

    var sortDescriptors: [SortDescriptor<CoffeeRecord>] {
        [SortDescriptor(\.rating, order: .reverse)]
    }
}
