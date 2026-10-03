import SwiftUI
import UIKit

/// デザイン決定（グレージュ × プラム）の色。ダークモードは「エスプレッソ」案（茶色がかった黒 × 明るいプラム）
extension Color {
    static let coffeeBackground = Color(light: 0xE9E5DF, dark: 0x1C1816)
    static let coffeeCard = Color(light: 0xF3F0EB, dark: 0x2A2421)
    static let coffeeSeparator = Color(light: 0xD6CFC7, dark: 0x3A322E)
    /// プラム。暗い背景では沈むので、ダークでは明るくする
    static let coffeeAccent = Color(light: 0x5B1F3B, dark: 0xD08AA8)
    /// アクセント色で塗った上に載せる文字・記号
    static let coffeeOnAccent = Color(light: 0xF3F0EB, dark: 0x1C1816)
    static let coffeeText = Color(light: 0x221A1E, dark: 0xEDE6E0)
    static let coffeeSecondaryText = Color(light: 0x5E555A, dark: 0xA99F99)
    static let coffeeStarOff = Color(light: 0xC9C0B8, dark: 0x4A413C)
    /// 焙煎度などの選択中の項目の背景
    static let coffeeSelectedFill = Color(light: 0xFFFFFF, dark: 0x4A413C)

    /// ライトとダークで切り替わる色。値は 0xRRGGBB
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
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
