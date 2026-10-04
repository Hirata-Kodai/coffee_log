import Foundation

extension RecordDraft {
    /// 豆のカードから読み取った値を下書きに入れる
    mutating func fillBlanks(from card: CardFields) {
        origin = card.origin ?? origin
        region = card.region ?? region
        farm = card.farm ?? farm
        variety = card.variety ?? variety
        process = card.process ?? process
        altitude = card.altitude ?? altitude
        tastingNotes = card.tastingNotes ?? tastingNotes
        roast = card.roast ?? roast
    }
}
