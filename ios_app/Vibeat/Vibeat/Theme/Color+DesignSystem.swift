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
