import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（アプリの ModelContainer）
// - [x] スキーマ v1 と移行計画を使うコンテナを作れる
// - [x] 既定は端末に保存し、inMemory ならメモリのみ（テスト・Preview 用）
@MainActor
struct CoffeeContainerTests {
    @Test func スキーマv1と移行計画を使うコンテナを作れる() throws {
        let container = try ModelContainer.coffeeLog(inMemory: true)

        #expect(container.schema == Schema(versionedSchema: CoffeeSchemaV1.self))
        let plan = try #require(container.migrationPlan)
        #expect(ObjectIdentifier(plan) == ObjectIdentifier(CoffeeMigrationPlan.self))
    }

    @Test func 既定は端末に保存しinMemoryならメモリのみにする() throws {
        let stored = try ModelContainer.coffeeLog()
        let inMemory = try ModelContainer.coffeeLog(inMemory: true)

        #expect(stored.configurations.map(\.isStoredInMemoryOnly) == [false])
        #expect(inMemory.configurations.map(\.isStoredInMemoryOnly) == [true])
    }
}
