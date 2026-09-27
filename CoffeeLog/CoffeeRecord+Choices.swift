import Foundation

/// 購入形態。保存は rawValue の文字列（検索・並べ替えの条件で扱いやすくするため）
enum PurchaseType: String, CaseIterable {
    case bean, ground, cafe, can, capsule, other

    var label: String {
        switch self {
        case .bean: "豆"
        case .ground: "粉"
        case .cafe: "カフェ"
        case .can: "缶"
        case .capsule: "カプセル"
        case .other: "その他"
        }
    }
}

/// 焙煎度。保存は rawValue の文字列
enum Roast: String, CaseIterable {
    case light, medium, mediumDark, dark

    var label: String {
        switch self {
        case .light: "浅煎り"
        case .medium: "中煎り"
        case .mediumDark: "中深煎り"
        case .dark: "深煎り"
        }
    }
}

extension CoffeeRecord {
    var purchaseType: PurchaseType? {
        get { purchaseTypeRaw.flatMap(PurchaseType.init(rawValue:)) }
        set { purchaseTypeRaw = newValue?.rawValue }
    }

    var roast: Roast? {
        get { roastRaw.flatMap(Roast.init(rawValue:)) }
        set { roastRaw = newValue?.rawValue }
    }
}
