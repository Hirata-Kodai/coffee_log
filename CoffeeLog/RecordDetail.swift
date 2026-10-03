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
        if let price = record.price {
            // 容量があれば「¥1,800 / 200g」のように価格の行にまとめる
            let value = [yen(price), record.volume].compactMap { $0 }.joined(separator: " / ")
            rows.append(Row(label: "価格", value: value))
        }
        return rows
    }

    /// ¥1,800。端末の地域設定によらず 3 桁区切りにする
    private static func yen(_ price: Int) -> String {
        "¥" + price.formatted(.number.locale(Locale(identifier: "ja_JP")))
    }
}
