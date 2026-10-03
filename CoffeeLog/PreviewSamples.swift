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
        // 写真・味・メモまで全部入った記録
        let ethiopia = record("エチオピア イルガチェフェ ゲデブ ナチュラル", rating: 5, day: 25, shop: "自家焙煎の店", roast: .light)
        ethiopia.purchaseType = .bean
        ethiopia.price = 1800
        ethiopia.volume = "200g"
        ethiopia.origin = "エチオピア"
        ethiopia.variety = "在来種"
        ethiopia.aroma = 5
        ethiopia.acidity = 4
        ethiopia.sweetness = 4
        ethiopia.body = 2
        ethiopia.aftertaste = 4
        ethiopia.bitterness = 1
        ethiopia.memo = "ベリーのような香り。冷めても甘さが残る。次はもう少し細挽きで淹れてみる。"
        ethiopia.photo = samplePhoto()

        // 写真なしで味が一部だけの記録
        let kenya = record("ケニア AB", rating: 4, day: 23, shop: "村上コーヒー", roast: .mediumDark)
        kenya.acidity = 5
        kenya.body = 3

        return [
            ethiopia,
            kenya,
            record("タンザニア", rating: 3, day: 23, minute: 30, shop: "NewDays", roast: .medium),
            record("グアテマラ アンティグア", rating: 4, day: 20, shop: "駅前のカフェ", roast: .mediumDark),
            record("ブラジル サントス", rating: 2, day: 18, roast: .dark),
            record("名前だけの記録", rating: 1, day: 15),
        ]
    }
}

/// 写真ありの表示を確かめるためのダミー画像（茶色のグラデーション）
private func samplePhoto() -> Data? {
    let size = CGSize(width: 1200, height: 900)
    let image = UIGraphicsImageRenderer(size: size).image { context in
        let colors = [UIColor(red: 0.45, green: 0.30, blue: 0.20, alpha: 1).cgColor,
                      UIColor(red: 0.85, green: 0.75, blue: 0.62, alpha: 1).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: [0, 1])!
        context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
    }
    return PhotoResizer.jpegData(from: image)
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleRecords: Self = .modifier(SampleRecords())
}
#endif
