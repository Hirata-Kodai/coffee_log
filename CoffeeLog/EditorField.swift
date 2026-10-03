import Foundation

/// 入力シートの文字入力欄。キーボード上の ^ ∨ で移る順に並べる
enum EditorField: CaseIterable {
    case name, shop, price, volume, origin, variety, memo

    func next(showsDetails: Bool) -> EditorField? {
        let fields = Self.allCases
        guard let index = fields.firstIndex(of: self), index + 1 < fields.count else { return nil }
        return fields[index + 1]
    }
}
