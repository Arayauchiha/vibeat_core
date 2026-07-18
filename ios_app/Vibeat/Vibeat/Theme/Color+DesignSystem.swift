import SwiftUI

extension Color {
    // Core Brand Colors
    static let inkPaper = Color(hex: "FAF8F5")
    static let tabletop = Color(hex: "111215")
    static let carbonInk = Color(hex: "1C1C1E")
    static let subtleDottedLine = Color(hex: "D1D1D6")
    static let terracottaOrange = Color(hex: "E65F2B")
    
    // Distressed Stamp Ink Colors
    static let goldStamp = Color(hex: "D49D0E")
    static let budgetStamp = Color(hex: "2B8A44")
    static let foodieStamp = Color(hex: "B33939")
    static let commuteStamp = Color(hex: "2F3542")
    static let rejectStamp = Color(hex: "7F8C8D")
    
    // Hex initializer helper
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Font {
    // Custom Brand Typography using System Serif (New York) and System Rounded (SF Pro Rounded)
    
    static func editorialHeader(size: CGFloat = 28) -> Font {
        return Font.system(size: size, weight: .bold, design: .serif)
    }
    
    static func editorialSubheader(size: CGFloat = 18) -> Font {
        return Font.system(size: size, weight: .medium, design: .serif)
    }
    
    static func uiLabel(size: CGFloat = 14, weight: Font.Weight = .regular) -> Font {
        return Font.system(size: size, weight: weight, design: .rounded)
    }
    
    static func uiNumber(size: CGFloat = 16, weight: Font.Weight = .bold) -> Font {
        return Font.system(size: size, weight: weight, design: .monospaced)
    }
}
