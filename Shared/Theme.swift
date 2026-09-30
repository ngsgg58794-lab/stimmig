import SwiftUI
import UIKit

enum AppColor {
    static let background = Color(light: "#FBFAF7", dark: "#141110")
    static let ink = Color(light: "#16130F", dark: "#F3EFE9")
    static let muted = Color(light: "#7A736B", dark: "#9D958B")
    static let line = Color(light: "#ECE7DF", dark: "#2F2A25")
    static let card = Color(light: "#FFFFFF", dark: "#1F1B18")
    static let highlight = Color(hex: "#FF2D78")
    static let highlightSoft = Color(light: "#FFE3EE", dark: "#3D1A28")
    static let ghostRing = Color(light: "#EEE9E1", dark: "#2A2521")
    static let bodyText = Color(light: "#3A342E", dark: "#D8D1C8")
    static let saved = Color(hex: "#1FBF75")
    /// Text on the pastel emotion colours — stays dark in both appearances.
    static let onEmotion = Color(hex: "#16130F")
}

extension Color {
    /// A colour that follows the system appearance (light/dark).
    init(light: String, dark: String) {
        let lightColor = UIColor(Color(hex: light))
        let darkColor = UIColor(Color(hex: dark))
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkColor : lightColor
        })
    }

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
