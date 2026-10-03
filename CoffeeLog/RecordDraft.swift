import Foundation

/// 入力画面で編集中の記録。保存できるかどうかを判定し、CoffeeRecord の新規作成と編集の反映を行う。
struct RecordDraft: Equatable {
    static let ratingRange = 1...5
    static let volumeUnit = "g"

    var name: String = ""
    /// 未選択は nil
    var rating: Int? = nil
    var date: Date = .now

    // 任意の文字列項目。空欄は "" で持ち、保存時に nil にそろえる
    var shop: String = ""
    /// 容量（g）の入力欄の数字。保存時に単位の g を付ける
    var volume: String = ""
    var origin: String = ""
    var variety: String = ""
    var memo: String = ""
    /// 価格（円）の入力欄の文字列。空欄は未入力
    var priceText: String = ""

    /// 新しい記録では豆を選んだ状態で始める
    var purchaseType: PurchaseType? = .bean
    var roast: Roast? = nil
    var photo: Data? = nil

    // 味 6 軸。各 1〜5、nil は未入力
    var aroma: Int? = nil
    var acidity: Int? = nil
    var sweetness: Int? = nil
    var body: Int? = nil
    var aftertaste: Int? = nil
    var bitterness: Int? = nil

    var canSave: Bool {
        hasName && hasValidRating && hasValidPrice
    }

    /// 保存できない下書きなら nil。now は作成日時になる。日付は calendar でその日の 0 時にそろえる
    func makeRecord(now: Date, calendar: Calendar = .current) -> CoffeeRecord? {
        guard canSave, let name = name.nilIfBlank, let rating else { return nil }
        let record = CoffeeRecord(name: name, rating: rating, date: calendar.startOfDay(for: date), createdAt: now)
        _ = apply(to: record, calendar: calendar)
        return record
    }

    /// 編集した内容を既存の記録に反映する。作成日時は変えない。保存できない下書きなら何もせず false
    func apply(to record: CoffeeRecord, calendar: Calendar = .current) -> Bool {
        guard canSave, let name = name.nilIfBlank, let rating else { return false }
        record.name = name
        record.rating = rating
        record.date = calendar.startOfDay(for: date)
        record.shop = shop.nilIfBlank
        record.volume = volume.nilIfBlank.map { $0 + Self.volumeUnit }
        record.origin = origin.nilIfBlank
        record.variety = variety.nilIfBlank
        record.memo = memo.nilIfBlank
        record.price = price
        record.purchaseType = purchaseType
        record.roast = roast
        record.photo = photo
        record.aroma = aroma
        record.acidity = acidity
        record.sweetness = sweetness
        record.body = body
        record.aftertaste = aftertaste
        record.bitterness = bitterness
        return true
    }

    /// 空欄なら nil
    private var price: Int? {
        priceText.nilIfBlank.flatMap { Int($0) }
    }

    private var hasName: Bool {
        name.nilIfBlank != nil
    }

    private var hasValidRating: Bool {
        guard let rating else { return false }
        return Self.ratingRange.contains(rating)
    }

    /// 空欄は有効。入力があれば 0 以上の整数として読めること
    private var hasValidPrice: Bool {
        guard priceText.nilIfBlank != nil else { return true }
        guard let price else { return false }
        return price >= 0
    }
}

extension RecordDraft {
    /// 編集用に既存の記録から下書きを作る。未入力の文字列は空欄、価格は入力欄の文字列にする
    init(record: CoffeeRecord) {
        self.init(
            name: record.name,
            rating: record.rating,
            date: record.date,
            shop: record.shop ?? "",
            volume: record.volume ?? "",
            origin: record.origin ?? "",
            variety: record.variety ?? "",
            memo: record.memo ?? "",
            priceText: record.price.map(String.init) ?? "",
            purchaseType: record.purchaseType,
            roast: record.roast,
            photo: record.photo,
            aroma: record.aroma,
            acidity: record.acidity,
            sweetness: record.sweetness,
            body: record.body,
            aftertaste: record.aftertaste,
            bitterness: record.bitterness
        )
    }
}
