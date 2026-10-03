import Foundation
import SwiftData
import Testing
@testable import CoffeeLog

// TODO（一覧の検索）
// - [x] 豆の名前の部分一致で絞り込む
// - [x] 店の名前では絞り込まない
// - [x] 大文字小文字を区別しない
// - [ ] 検索欄の前後の空白は無視する
// - [ ] 検索欄が空欄なら絞り込まない
@MainActor
struct RecordSearchTests {
    /// 名称と店の組を入れて検索し、当たった名称を返す。並び順は検索の関心ではないので Set にする
    private func search(_ text: String, in records: [(name: String, shop: String?)]) throws -> Set<String> {
        let container = try ModelContainer.coffeeLog(inMemory: true)
        let context = container.mainContext
        for (name, shop) in records {
            let record = CoffeeRecord(name: name, rating: 3, date: .now, createdAt: .now)
            record.shop = shop
            context.insert(record)
        }
        try context.save()
        let descriptor = FetchDescriptor(predicate: RecordSearch.predicate(matching: text))
        return Set(try context.fetch(descriptor).map(\.name))
    }

    @Test func 豆の名前の部分一致で絞り込む() throws {
        let names = try search("ケニア", in: [
            ("ケニア AB", nil),
            ("タンザニア", nil),
            ("東ケニア ナチュラル", nil),
        ])

        #expect(names == ["ケニア AB", "東ケニア ナチュラル"])
    }

    @Test func 店の名前では絞り込まない() throws {
        let names = try search("村上", in: [
            ("ケニア AB", "村上コーヒー"),
            ("村上ブレンド", nil),
        ])

        #expect(names == ["村上ブレンド"])
    }

    @Test func 大文字小文字を区別しない() throws {
        let names = try search("kenya", in: [
            ("Kenya AA", nil),
            ("KENYA Peaberry", nil),
            ("Brazil", nil),
        ])

        #expect(names == ["KENYA Peaberry", "Kenya AA"])
    }
}
