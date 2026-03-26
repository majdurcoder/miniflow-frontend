import SwiftUI

// MARK: - Color(hex:)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:   Double(r) / 255,
                  green: Double(g) / 255,
                  blue:  Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Design tokens

extension Color {
    static let tealDark   = Color(hex: "009684")
    static let tealLight  = Color(hex: "66CDBA")
    static let miniflowTealDark  = Color(hex: "009684")
    static let miniflowTealLight = Color(hex: "66CDBA")
    static let sidebar           = Color(hex: "FAFAFA")
    static let miniflowSidebar   = Color(hex: "FAFAFA")
    static let rowBorder         = Color(hex: "F3F4F6")
    static let miniflowBorder    = Color(hex: "F3F4F6")
    static let otpBoxBg          = Color(hex: "FAFAFA")
    static let otpBoxBorder      = Color(hex: "F5F5F5")
    static let miniflowTextSecondary = Color(hex: "737373")
    static let miniflowTextTertiary  = Color(hex: "A1A1A1")
    static let miniflowTextPrimary   = Color(hex: "1F2937")
    static let trafficRed    = Color(hex: "FF5F57")
    static let trafficYellow = Color(hex: "FFBD2E")
    static let trafficGreen  = Color(hex: "28C840")
}

// MARK: - Font helpers

extension Font {
    static func geist(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func geistMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}
