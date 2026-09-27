import Foundation
import SwiftData

/// 保存データのスキーマ v1。項目の型や意味を変えるときは V2 を追加し、CoffeeMigrationPlan に移行手順を足す。
enum CoffeeSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

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
        /// 自由入力（200g、R など）
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

        init(name: String, rating: Int, date: Date, createdAt: Date) {
            self.name = name
            self.rating = rating
            self.date = date
            self.createdAt = createdAt
        }
    }
}

typealias CoffeeRecord = CoffeeSchemaV1.CoffeeRecord

enum CoffeeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CoffeeSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
