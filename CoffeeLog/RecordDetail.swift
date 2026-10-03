import Foundation

/// 詳細画面に出す内容を記録から組み立てる
enum RecordDetail {
    /// 基本情報の 1 行
    struct Row: Equatable {
        let label: String
        let value: String
    }

    /// 入力済みの項目だけを返す
    static func infoRows(for record: CoffeeRecord) -> [Row] {
        []
    }
}
