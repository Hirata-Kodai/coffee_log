import Foundation

/// 一覧の並び順
enum RecordSortOrder: String {
    /// 評価の高い順（比べる）
    case rating
    /// 新しい順（振り返る）
    case newest

    var sortDescriptors: [SortDescriptor<CoffeeRecord>] {
        switch self {
        case .rating: [SortDescriptor(\.rating, order: .reverse)] + Self.newestFirst
        case .newest: Self.newestFirst
        }
    }

    /// 日付が新しい順。同じ日なら後から作った記録を上にする
    private static let newestFirst: [SortDescriptor<CoffeeRecord>] = [
        SortDescriptor(\.date, order: .reverse),
        SortDescriptor(\.createdAt, order: .reverse),
    ]
}
