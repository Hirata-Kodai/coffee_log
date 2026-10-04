import Foundation

/// 入力シートの文字入力欄。キーボード上の ^ ∨ で移る順に並べる
enum EditorField: CaseIterable {
    case name, shop, price, volume, origin, region, farm, variety, process, altitude, tastingNotes, memo

    /// 詳細（初期は閉じる）の中にある欄
    var isInDetails: Bool {
        switch self {
        case .origin, .region, .farm, .variety, .process, .altitude, .tastingNotes, .memo: true
        case .name, .shop, .price, .volume: false
        }
    }

    func next(showsDetails: Bool) -> EditorField? {
        let fields = Self.visible(showsDetails: showsDetails)
        guard let index = fields.firstIndex(of: self), index + 1 < fields.count else { return nil }
        return fields[index + 1]
    }

    func previous(showsDetails: Bool) -> EditorField? {
        let fields = Self.visible(showsDetails: showsDetails)
        guard let index = fields.firstIndex(of: self), index > 0 else { return nil }
        return fields[index - 1]
    }

    /// 閉じている詳細の欄は飛ばす
    private static func visible(showsDetails: Bool) -> [EditorField] {
        allCases.filter { showsDetails || !$0.isInDetails }
    }
}
