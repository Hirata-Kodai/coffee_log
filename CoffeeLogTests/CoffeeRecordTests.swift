import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（CoffeeRecord のモデル定義）
// - [x] スキーマ v1 で全項目を保存して読み出せる
// - [ ] 購入形態・焙煎度は enum で読み書きでき、保存は文字列になる
@MainActor
struct CoffeeRecordTests {
    /// ModelContainer が解放されると context も使えなくなるので、container ごと返して保持する
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: CoffeeSchemaV1.self),
            migrationPlan: CoffeeMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func スキーマv1で全項目を保存して読み出せる() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let date = Date(timeIntervalSince1970: 1_790_000_000)
        let createdAt = Date(timeIntervalSince1970: 1_790_000_100)
        let record = CoffeeRecord(name: "ケニア AB", rating: 4, date: date, createdAt: createdAt)
        record.shop = "村上コーヒー"
        record.purchaseTypeRaw = "bean"
        record.roastRaw = "mediumDark"
        record.price = 1200
        record.volume = "100g"
        record.photo = Data([0x01, 0x02])
        record.aroma = 4
        record.acidity = 3
        record.sweetness = 2
        record.body = 5
        record.aftertaste = 4
        record.bitterness = 1
        record.origin = "ケニア"
        record.variety = "SL28"
        record.memo = "ベリーの香り"
        context.insert(record)
        try context.save()

        let fetched = try #require(try context.fetch(FetchDescriptor<CoffeeRecord>()).first)
        #expect(fetched.name == "ケニア AB")
        #expect(fetched.rating == 4)
        #expect(fetched.date == date)
        #expect(fetched.createdAt == createdAt)
        #expect(fetched.shop == "村上コーヒー")
        #expect(fetched.purchaseTypeRaw == "bean")
        #expect(fetched.roastRaw == "mediumDark")
        #expect(fetched.price == 1200)
        #expect(fetched.volume == "100g")
        #expect(fetched.photo == Data([0x01, 0x02]))
        #expect([fetched.aroma, fetched.acidity, fetched.sweetness,
                 fetched.body, fetched.aftertaste, fetched.bitterness] == [4, 3, 2, 5, 4, 1])
        #expect(fetched.origin == "ケニア")
        #expect(fetched.variety == "SL28")
        #expect(fetched.memo == "ベリーの香り")
    }
}
