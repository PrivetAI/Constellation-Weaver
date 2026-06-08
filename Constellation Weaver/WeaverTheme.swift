import SwiftUI

// Fixed dark "night sky" palette. Hard-coded RGB values so the appearance
// never changes with the device's light/dark setting.
enum WeaverTheme {
    static let skyTop      = Color(red: 0.035, green: 0.047, blue: 0.105) // deep navy
    static let skyBottom   = Color(red: 0.078, green: 0.063, blue: 0.149) // violet-night
    static let panel       = Color(red: 0.090, green: 0.098, blue: 0.176)
    static let panelRaised = Color(red: 0.129, green: 0.137, blue: 0.235)
    static let stroke      = Color(red: 0.231, green: 0.247, blue: 0.376)

    static let textPrimary   = Color(red: 0.918, green: 0.937, blue: 1.0)
    static let textSecondary = Color(red: 0.643, green: 0.682, blue: 0.847)
    static let textFaint     = Color(red: 0.435, green: 0.470, blue: 0.639)

    static let starCore = Color(red: 1.0, green: 0.992, blue: 0.929)
    static let line     = Color(red: 0.741, green: 0.835, blue: 1.0)

    // Per-sky accent hues so different regions feel distinct.
    static func accent(_ hueIndex: Int) -> Color {
        switch hueIndex % 4 {
        case 0: return Color(red: 0.541, green: 0.745, blue: 1.0)   // ice blue
        case 1: return Color(red: 0.984, green: 0.776, blue: 0.490) // warm amber
        case 2: return Color(red: 0.757, green: 0.690, blue: 1.0)   // soft violet
        default: return Color(red: 0.522, green: 0.918, blue: 0.808) // mint teal
        }
    }

    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [skyTop, skyBottom]),
        startPoint: .top, endPoint: .bottom)
}
