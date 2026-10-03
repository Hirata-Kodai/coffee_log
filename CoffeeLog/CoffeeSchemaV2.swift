import Foundation
import SwiftData

/// 保存データのスキーマ v2。v1 に豆のカードによく書かれている項目（農園・精製方法・地域・標高・テイスティングノート）を足した
enum CoffeeSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [CoffeeRecord.self]
    }

    /// 1 杯分の記録
    @Model
    final class CoffeeRecord {
        var name: String
        /// 1〜5
        var rating: Int
        /// 飲んだ日
        var date: Date
        /// 並び順のタイブレーク用。画面には出さない
        var createdAt: Date

        var shop: String?
        var purchaseTypeRaw: String?
        var roastRaw: String?
        /// 円
        var price: Int?
        /// 「200g」の形
        var volume: String?
        @Attribute(.externalStorage) var photo: Data?

        // 味 6 軸。各 1〜5、nil は未入力
        var aroma: Int?
        var acidity: Int?
        var sweetness: Int?
        var body: Int?
        var aftertaste: Int?
        var bitterness: Int?

        var origin: String?
        var variety: String?
        var memo: String?

        // v2 で追加。どれも自由入力の文字列
        /// 生産国より細かい産地（イルガチェフェなど）
        var region: String?
        var farm: String?
        /// 精製方法（ナチュラル、ウォッシュトなど）
        var process: String?
        /// 幅で書かれることが多いので文字列（1,900–2,100m など）
        var altitude: String?
        /// 店の説明にある風味（ベリー、ジャスミンなど）。自分のメモとは分ける
        var tastingNotes: String?

        init(name: String, rating: Int, date: Date, createdAt: Date) {
            self.name = name
            self.rating = rating
            self.date = date
            self.createdAt = createdAt
        }
    }
}
