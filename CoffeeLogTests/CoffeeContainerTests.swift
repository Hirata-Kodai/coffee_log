import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（アプリの ModelContainer）
// - [x] スキーマ v1 と移行計画を使うコンテナを作れる
// - [ ] メモリのみのコンテナを作れる（テスト・Preview 用）
@MainActor
struct CoffeeContainerTests {
    @Test func スキーマv1と移行計画を使うコンテナを作れる() throws {
        let container = try ModelContainer.coffeeLog(inMemory: true)

        #expect(container.schema == Schema(versionedSchema: CoffeeSchemaV1.self))
        let plan = try #require(container.migrationPlan)
        #expect(ObjectIdentifier(plan) == ObjectIdentifier(CoffeeMigrationPlan.self))
    }
}
