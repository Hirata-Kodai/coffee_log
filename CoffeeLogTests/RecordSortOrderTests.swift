import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（一覧の並び順）
// - [x] 評価の高い順は評価の降順
// - [ ] 評価の高い順で評価が同じなら日付の新しい順
// - [ ] 評価の高い順で評価も日付も同じなら作成日時の新しい順
// - [ ] 新しい順は日付の降順
// - [ ] 新しい順で日付が同じなら作成日時の新しい順
@MainActor
struct RecordSortOrderTests {
    private static let day1 = Date(timeIntervalSince1970: 1_789_000_000)
    private static let day2 = day1.addingTimeInterval(86_400)

    /// 記録を入れて並び順どおりに取り出し、名称の並びを返す
    private func fetchNames(_ records: [CoffeeRecord], order: RecordSortOrder) throws -> [String] {
        let container = try ModelContainer.coffeeLog(inMemory: true)
        let context = container.mainContext
        records.forEach(context.insert)
        try context.save()
        return try context.fetch(FetchDescriptor(sortBy: order.sortDescriptors)).map(\.name)
    }

    private func record(_ name: String, rating: Int, date: Date = day1, createdAt: Date = day1) -> CoffeeRecord {
        CoffeeRecord(name: name, rating: rating, date: date, createdAt: createdAt)
    }

    @Test func 評価の高い順は評価の降順() throws {
        let names = try fetchNames([
            record("3", rating: 3),
            record("5", rating: 5),
            record("1", rating: 1),
        ], order: .rating)

        #expect(names == ["5", "3", "1"])
    }
}
