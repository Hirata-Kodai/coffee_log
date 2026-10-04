import Foundation

extension RecordDraft {
    /// 豆のカードから読み取った値を、下書きの空欄だけに入れる（自分で入れた値は変えない）。入れた項目の数を返す
    @discardableResult
    mutating func fillBlanks(from card: CardFields) -> Int {
        var filled = 0
        let pairs: [(draft: WritableKeyPath<RecordDraft, String>, card: KeyPath<CardFields, String?>)] = [
            (\.origin, \.origin),
            (\.region, \.region),
            (\.farm, \.farm),
            (\.variety, \.variety),
            (\.process, \.process),
            (\.altitude, \.altitude),
            (\.tastingNotes, \.tastingNotes),
        ]
        for (draftField, cardField) in pairs {
            // 空白だけの欄は空欄と見なす
            if self[keyPath: draftField].nilIfBlank == nil, let value = card[keyPath: cardField] {
                self[keyPath: draftField] = value
                filled += 1
            }
        }
        if roast == nil, let cardRoast = card.roast {
            roast = cardRoast
            filled += 1
        }
        return filled
    }
}
