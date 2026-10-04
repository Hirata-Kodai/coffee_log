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
        } else if let volume = record.volume {
            rows.append(Row(label: "容量", value: volume))
        }
        // 産地の大きい順（生産国 → 地域 → 農園）に並べ、そのあとに豆と精製の情報を続ける
        let texts: [(label: String, value: String?)] = [
            ("生産国", record.origin),
            ("地域", record.region),
            ("農園", record.farm),
            ("品種", record.variety),
            ("精製方法", record.process),
            ("標高", record.altitude),
        ]
        for (label, value) in texts {
            if let value {
                rows.append(Row(label: label, value: value))
            }
        }
        return rows
    }

    /// 味 6 軸の値
    struct Taste: Equatable {
        let values: [(name: String, value: Int?)]

        /// チャートの下に出す文。読み上げにも使う
        var summary: String {
            let parts = values.map { "\($0.name) \($0.value.map(String.init) ?? "-")" }
            return parts.joined(separator: " · ") + "（5段階）"
        }

        static func == (lhs: Taste, rhs: Taste) -> Bool {
            lhs.values.elementsEqual(rhs.values) { $0.name == $1.name && $0.value == $1.value }
        }
    }

    /// 全部未入力なら nil（チャートを出さない）
    static func taste(for record: CoffeeRecord) -> Taste? {
        let values: [(name: String, value: Int?)] = [
            ("香り", record.aroma),
            ("酸味", record.acidity),
            ("甘さ", record.sweetness),
            ("コク", record.body),
            ("後味", record.aftertaste),
            ("苦味", record.bitterness),
        ]
        guard values.contains(where: { $0.value != nil }) else { return nil }
        return Taste(values: values)
    }

    /// ¥1,800。端末の地域設定によらず 3 桁区切りにする
    private static func yen(_ price: Int) -> String {
        "¥" + price.formatted(.number.locale(Locale(identifier: "ja_JP")))
    }
}
