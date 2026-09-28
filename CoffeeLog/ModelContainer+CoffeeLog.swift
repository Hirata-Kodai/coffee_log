import Foundation
import SwiftData

extension ModelContainer {
    /// アプリで使うコンテナ。inMemory はテスト・Preview 用
    static func coffeeLog(inMemory: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: CoffeeSchemaV1.self),
            migrationPlan: CoffeeMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
        )
    }
}
