import Testing
@testable import CoffeeLog

// TODO（入力シートのキーボード上の ^ ∨ で移る順番）
// - [x] 次の欄は 名称 → 店 → 価格 → 容量 の順
// - [x] 詳細を開いていれば 容量 の次は 生産国 → 品種 → メモ
// - [x] 詳細を閉じていれば 容量 が最後
// - [x] 前の欄は逆順で、名称 が最初
struct EditorFieldTests {
    @Test func 次の欄は名称から容量の順() {
        #expect(EditorField.name.next(showsDetails: false) == .shop)
        #expect(EditorField.shop.next(showsDetails: false) == .price)
        #expect(EditorField.price.next(showsDetails: false) == .volume)
    }

    @Test func 詳細を開いていれば容量の次は生産国から品種とメモ() {
        #expect(EditorField.volume.next(showsDetails: true) == .origin)
        #expect(EditorField.origin.next(showsDetails: true) == .variety)
        #expect(EditorField.variety.next(showsDetails: true) == .memo)
        #expect(EditorField.memo.next(showsDetails: true) == nil)
    }

    @Test func 詳細を閉じていれば容量が最後() {
        #expect(EditorField.volume.next(showsDetails: false) == nil)
    }

    @Test func 前の欄は逆順で名称が最初() {
        #expect(EditorField.origin.previous(showsDetails: true) == .volume)
        #expect(EditorField.shop.previous(showsDetails: false) == .name)
        #expect(EditorField.name.previous(showsDetails: false) == nil)
    }
}
