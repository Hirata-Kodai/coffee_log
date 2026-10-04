import Foundation
import SwiftData

extension ModelContainer {
    /// アプリで使うコンテナ。inMemory はテスト・Preview 用、url は保存先のファイルを指定するとき（移行のテスト用）
    static func coffeeLog(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let configuration = if let url {
            ModelConfiguration(url: url)
        } else {
            ModelConfiguration(isStoredInMemoryOnly: inMemory)
        }
        return try ModelContainer(
            for: Schema(versionedSchema: CoffeeSchemaV2.self),
            migrationPlan: CoffeeMigrationPlan.self,
            configurations: configuration
        )
    }
}
