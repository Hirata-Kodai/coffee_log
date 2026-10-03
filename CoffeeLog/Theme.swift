import SwiftUI

/// デザイン決定（グレージュ × プラム）の色。ダークモードの配色は未定
extension Color {
    static let coffeeBackground = Color(red: 0xE9 / 255, green: 0xE5 / 255, blue: 0xDF / 255)
    static let coffeeCard = Color(red: 0xF3 / 255, green: 0xF0 / 255, blue: 0xEB / 255)
    static let coffeeSeparator = Color(red: 0xD6 / 255, green: 0xCF / 255, blue: 0xC7 / 255)
    static let coffeeAccent = Color(red: 0x5B / 255, green: 0x1F / 255, blue: 0x3B / 255)
    static let coffeeText = Color(red: 0x22 / 255, green: 0x1A / 255, blue: 0x1E / 255)
    static let coffeeSecondaryText = Color(red: 0x5E / 255, green: 0x55 / 255, blue: 0x5A / 255)
    static let coffeeStarOff = Color(red: 0xC9 / 255, green: 0xC0 / 255, blue: 0xB8 / 255)
}

extension Font {
    /// 豆の名前: ヒラギノ明朝 W6。Dynamic Type に追従する
    static func coffeeName(size: CGFloat) -> Font {
        .custom("HiraMinProN-W6", size: size, relativeTo: .body)
    }

    /// タイトル・日付: Oswald の代わりに SF の condensed で寄せる
    static func coffeeCondensed(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }
}
