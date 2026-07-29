// DesignSystem.swift
// Battery Insight Pro — Colors, typography, and visual tokens

import SwiftUI

// MARK: - Color Palette
extension Color {
    static let bip = BIPColors()
}

struct BIPColors {
    let accent      = Color(hue: 0.58, saturation: 0.85, brightness: 0.95)
    let green       = Color(hue: 0.38, saturation: 0.80, brightness: 0.85)
    let orange      = Color(hue: 0.08, saturation: 0.85, brightness: 0.95)
    let red         = Color(hue: 0.00, saturation: 0.82, brightness: 0.92)
    let yellow      = Color(hue: 0.13, saturation: 0.90, brightness: 0.98)
    let purple      = Color(hue: 0.75, saturation: 0.75, brightness: 0.90)
    let mint        = Color(hue: 0.45, saturation: 0.70, brightness: 0.88)
    let cardBG      = Color("cardBackground")
    let surface     = Color("surfaceColor")

    // Gradient pairs
    let batteryGradient  = [Color(hue: 0.38, saturation: 0.80, brightness: 0.85),
                            Color(hue: 0.50, saturation: 0.75, brightness: 0.90)]
    let accentGradient   = [Color(hue: 0.55, saturation: 0.90, brightness: 0.95),
                            Color(hue: 0.65, saturation: 0.80, brightness: 0.88)]
    let dangerGradient   = [Color(hue: 0.00, saturation: 0.85, brightness: 0.92),
                            Color(hue: 0.08, saturation: 0.88, brightness: 0.95)]
    let warmGradient     = [Color(hue: 0.07, saturation: 0.85, brightness: 0.95),
                            Color(hue: 0.13, saturation: 0.90, brightness: 0.98)]
    let backgroundGrad   = [Color(hue: 0.60, saturation: 0.10, brightness: 0.08),
                            Color(hue: 0.62, saturation: 0.12, brightness: 0.05)]
}

// MARK: - Fonts
struct BIPFont {
    static func largeTitle(weight: Font.Weight = .bold) -> Font {
        .system(size: 34, weight: weight, design: .rounded)
    }
    static func title(weight: Font.Weight = .semibold) -> Font {
        .system(size: 28, weight: weight, design: .rounded)
    }
    static func title2(weight: Font.Weight = .semibold) -> Font {
        .system(size: 22, weight: weight, design: .rounded)
    }
    static func headline(weight: Font.Weight = .semibold) -> Font {
        .system(size: 17, weight: weight, design: .rounded)
    }
    static func body(weight: Font.Weight = .regular) -> Font {
        .system(size: 15, weight: weight, design: .rounded)
    }
    static func caption(weight: Font.Weight = .medium) -> Font {
        .system(size: 12, weight: weight, design: .rounded)
    }
    static func mono(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

// MARK: - Spacing
enum BIPSpacing {
    static let xs: CGFloat  = 4
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 24
    static let xl: CGFloat  = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum BIPRadius {
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 14
    static let lg: CGFloat  = 20
    static let xl: CGFloat  = 28
    static let pill: CGFloat = 100
}

// MARK: - Background Gradient
struct BIPBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.60, saturation: 0.12, brightness: 0.08),
                Color(hue: 0.62, saturation: 0.15, brightness: 0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Availability badge color helper
extension MetricAvailability {
    var color: Color {
        switch self {
        case .live:        return Color.bip.green
        case .estimated:   return Color.bip.yellow
        case .unavailable: return Color.gray
        }
    }
    var label: String {
        switch self {
        case .live:        return "Live"
        case .estimated:   return "Est."
        case .unavailable: return "N/A"
        }
    }
    var icon: String {
        switch self {
        case .live:        return "circle.fill"
        case .estimated:   return "waveform"
        case .unavailable: return "slash.circle"
        }
    }
}
