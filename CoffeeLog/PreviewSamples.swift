#if DEBUG
import SwiftData
import SwiftUI

/// Preview 用のサンプル記録（長い名前、空欄の多い記録、同じ日の複数記録を含む）
struct SampleRecords: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer.coffeeLog(inMemory: true)
        for record in makeRecords() {
            container.mainContext.insert(record)
        }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }

    private static func makeRecords() -> [CoffeeRecord] {
        let calendar = Calendar.current
        func day(_ day: Int) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day))!
        }
        func record(_ name: String, rating: Int, day d: Int, minute: Int = 0,
                    shop: String? = nil, roast: Roast? = nil) -> CoffeeRecord {
            let record = CoffeeRecord(name: name, rating: rating, date: day(d),
                                      createdAt: day(d).addingTimeInterval(TimeInterval(minute * 60)))
            record.shop = shop
            record.roast = roast
            return record
        }
        return [
            record("エチオピア イルガチェフェ ゲデブ ナチュラル", rating: 5, day: 25, shop: "自家焙煎の店", roast: .light),
            record("ケニア AB", rating: 4, day: 23, shop: "村上コーヒー", roast: .mediumDark),
            record("タンザニア", rating: 3, day: 23, minute: 30, shop: "NewDays", roast: .medium),
            record("グアテマラ アンティグア", rating: 4, day: 20, shop: "駅前のカフェ", roast: .mediumDark),
            record("ブラジル サントス", rating: 2, day: 18, roast: .dark),
            record("名前だけの記録", rating: 1, day: 15),
        ]
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleRecords: Self = .modifier(SampleRecords())
}
#endif
