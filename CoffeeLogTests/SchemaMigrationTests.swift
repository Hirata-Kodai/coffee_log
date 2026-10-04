import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（スキーマ v1 → v2 の移行）
// - [x] v1 で保存した記録を v2 のアプリで開くと、既存の項目は残り、新しい項目は nil
@MainActor
struct SchemaMigrationTests {
    @Test func v1で保存した記録をv2で開くと既存の項目は残り新しい項目はnil() throws {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "migration-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: url) }

        // v1 のアプリで保存する
        do {
            let v1 = try ModelContainer(
                for: Schema(versionedSchema: CoffeeSchemaV1.self),
                configurations: ModelConfiguration(url: url)
            )
            let record = CoffeeSchemaV1.CoffeeRecord(name: "ケニア AB", rating: 4, date: .now, createdAt: .now)
            record.origin = "ケニア"
            v1.mainContext.insert(record)
            try v1.mainContext.save()
        }

        // v2 のアプリで開く
        let v2 = try ModelContainer.coffeeLog(url: url)
        let record = try #require(try v2.mainContext.fetch(FetchDescriptor<CoffeeRecord>()).first)

        #expect(record.name == "ケニア AB")
        #expect(record.rating == 4)
        #expect(record.origin == "ケニア")
        #expect([record.farm, record.process, record.region, record.altitude, record.tastingNotes]
                == [nil, nil, nil, nil, nil])
    }
}
