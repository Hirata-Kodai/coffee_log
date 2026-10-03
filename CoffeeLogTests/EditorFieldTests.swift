import Testing
@testable import CoffeeLog

// TODO（入力シートのキーボード上の ^ ∨ で移る順番）
// - [x] 次の欄は 名称 → 店 → 価格 → 容量 の順
// - [ ] 詳細を開いていれば 容量 の次は 生産国 → 品種 → メモ
// - [ ] 詳細を閉じていれば 容量 が最後
// - [ ] 前の欄は逆順で、名称 が最初
struct EditorFieldTests {
    @Test func 次の欄は名称から容量の順() {
        #expect(EditorField.name.next(showsDetails: false) == .shop)
        #expect(EditorField.shop.next(showsDetails: false) == .price)
        #expect(EditorField.price.next(showsDetails: false) == .volume)
    }
}
