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
        var rows: [Row] = []
        if let purchaseType = record.purchaseType {
            rows.append(Row(label: "購入形態", value: purchaseType.label))
        }
        if let roast = record.roast {
            rows.append(Row(label: "焙煎度", value: roast.label))
        }
        return rows
    }
}
