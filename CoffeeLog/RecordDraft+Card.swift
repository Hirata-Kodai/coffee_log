import Foundation

extension RecordDraft {
    /// 豆のカードから読み取った値を、下書きの空欄だけに入れる（自分で入れた値は変えない）
    mutating func fillBlanks(from card: CardFields) {
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
            }
        }
        if roast == nil {
            roast = card.roast
        }
    }
}
