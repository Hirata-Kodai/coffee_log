import Foundation
import SwiftData

/// アプリで使う記録の型。常に最新のスキーマを指す
typealias CoffeeRecord = CoffeeSchemaV2.CoffeeRecord

/// スキーマの移行手順。項目の型や意味を変えるときは新しい版を追加し、ここに手順を足す
enum CoffeeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CoffeeSchemaV1.self, CoffeeSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [v1ToV2]
    }

    /// 任意の項目を足しただけなので軽量移行で済む（既存の記録では新しい項目が nil になる）
    static let v1ToV2 = MigrationStage.lightweight(fromVersion: CoffeeSchemaV1.self, toVersion: CoffeeSchemaV2.self)
}
