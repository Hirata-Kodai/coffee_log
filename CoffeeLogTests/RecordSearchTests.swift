import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（一覧の検索）
// - [x] 豆の名前の部分一致で絞り込む
// - [ ] 店の名前では絞り込まない
// - [ ] 大文字小文字を区別しない
// - [ ] 検索欄の前後の空白は無視する
// - [ ] 検索欄が空欄なら絞り込まない
@MainActor
struct RecordSearchTests {
    /// 名称と店の組を入れて検索し、当たった名称を名前順で返す
    private func search(_ text: String, in records: [(name: String, shop: String?)]) throws -> [String] {
        let container = try ModelContainer.coffeeLog(inMemory: true)
        let context = container.mainContext
        for (name, shop) in records {
            let record = CoffeeRecord(name: name, rating: 3, date: .now, createdAt: .now)
            record.shop = shop
            context.insert(record)
        }
        try context.save()
        let descriptor = FetchDescriptor(predicate: RecordSearch.predicate(matching: text), sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor).map(\.name)
    }

    @Test func 豆の名前の部分一致で絞り込む() throws {
        let names = try search("ケニア", in: [
            ("ケニア AB", nil),
            ("タンザニア", nil),
            ("東ケニア ナチュラル", nil),
        ])

        #expect(names == ["ケニア AB", "東ケニア ナチュラル"])
    }
}
