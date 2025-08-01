
import SwiftUI

struct AppColors {
    static let primaryColor = Color(red: 0.3, green: 0.1, blue: 0.6)
    static let lightPurple = Color(red: 0.85, green: 0.7, blue: 0.95)
    static let lightGray = Color(white: 0.95)
    static let darkGray = Color(white: 0.6)
    static let accentColor = Color(red: 0.1, green: 0.7, blue: 0.3)
    static let errorColor = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let warningColor = Color(red: 0.9, green: 0.6, blue: 0.2)
}

// SwiftUI Color extension for hex initialization
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

// UIColor extension for hex initialization (for UIKit usage)
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

