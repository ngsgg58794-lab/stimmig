import SwiftUI
import UIKit

enum AppColor {
    static let background = Color(hex: "#FBFAF7")
    static let ink = Color(hex: "#16130F")
    static let muted = Color(hex: "#7A736B")
    static let line = Color(hex: "#ECE7DF")
    static let card = Color(hex: "#FFFFFF")
    static let highlight = Color(hex: "#FF2D78")
    static let highlightSoft = Color(hex: "#FFE3EE")
    static let ghostRing = Color(hex: "#EEE9E1")
    static let bodyText = Color(hex: "#3A342E")
    static let saved = Color(hex: "#1FBF75")
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// Mixes this color toward white by fraction `t` (0...1), matching the web app's `mix()` helper.
    func mixedWithWhite(_ t: Double) -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let nr = r + (1 - r) * CGFloat(t)
        let ng = g + (1 - g) * CGFloat(t)
        let nb = b + (1 - b) * CGFloat(t)
        return Color(red: Double(nr), green: Double(ng), blue: Double(nb))
    }
}

extension Font {
    /// Stand-in for the web app's "Bricolage Grotesque" display font using SF Rounded.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
