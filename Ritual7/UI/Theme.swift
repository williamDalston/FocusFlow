import SwiftUI

// MARK: - Design System

/// App-wide theme: typography, colors, strokes, shadows.
enum Theme {
    
    // MARK: - Color Themes
    
    enum ColorTheme: String, CaseIterable {
        case feminine = "Feminine"
        case masculine = "Masculine"
        
        var displayName: String {
            switch self {
            case .feminine: return "Soft & Gentle"
            case .masculine: return "Bold & Strong"
            }
        }
        
        var description: String {
            switch self {
            case .feminine: return "Warm purples and soft blues"
            case .masculine: return "Deep blues and rich teals"
            }
        }
    }
    
    // Current theme (will be set by ThemeStore)
    static var currentTheme: ColorTheme = .feminine

    // MARK: - Typography System (Refined for Elegance)
    
    // Typography - Dynamic Type compatible with refined weights
    // Note: Letter spacing (tracking) should be applied via .kerning() or .tracking() on Text views, not Font
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title      = Font.system(.title, design: .rounded).weight(.bold)
    static let title2     = Font.system(.title2, design: .rounded).weight(.bold)
    static let title3     = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headline   = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body       = Font.system(.body, design: .rounded).weight(.regular)
    static let subheadline = Font.system(.subheadline, design: .rounded).weight(.regular)
    static let caption    = Font.system(.caption, design: .rounded).weight(.medium)
    static let caption2   = Font.system(.caption2, design: .rounded).weight(.medium)
    static let footnote   = Font.system(.footnote, design: .rounded).weight(.regular)
    
    // Legacy aliases for backward compatibility
    static let section = title3
    static let small   = footnote
    
    // Dynamic Type support with refined letter spacing
    static func dynamicTitle(for sizeClass: UserInterfaceSizeClass?) -> Font {
        switch sizeClass {
        case .regular:
            return .system(.largeTitle, design: .rounded).weight(.bold)
        default:
            return .system(.title, design: .rounded).weight(.bold)
        }
    }
    
    // Typography helpers with line heights for better readability
    static func titleFont(sizeClass: UserInterfaceSizeClass? = nil) -> Font {
        dynamicTitle(for: sizeClass)
    }
    
    static func sectionFont() -> Font {
        title3
    }
    
    static func bodyFont() -> Font {
        body
    }
    
    static func captionFont() -> Font {
        caption
    }

    // MARK: - Enhanced Color Palettes (Sophisticated & Elegant)
    
    // Feminine Theme - Refined with sophisticated color harmony
    // Based on color theory: harmonious purple-blue palette with refined saturation
    // Lightened for better visual appeal and less darkness
    private static let feminineAccentA = Color(hue: 0.75, saturation: 0.68, brightness: 0.85) // elegant lavender - lighter and brighter
    private static let feminineAccentB = Color(hue: 0.58, saturation: 0.74, brightness: 0.88) // refined periwinkle - lighter and brighter
    private static let feminineAccentC = Color(hue: 0.80, saturation: 0.64, brightness: 0.80) // deep amethyst - lighter
    private static let feminineAccentD = Color(hue: 0.70, saturation: 0.62, brightness: 0.86) // soft violet - lighter
    private static let feminineAccentE = Color(hue: 0.56, saturation: 0.72, brightness: 0.90) // light periwinkle - lighter
    
    // Masculine Theme - Refined with sophisticated color harmony
    // Based on color theory: harmonious blue-teal palette with refined saturation
    private static let masculineAccentA = Color(hue: 0.54, saturation: 0.72, brightness: 0.72) // sophisticated navy - elegant
    private static let masculineAccentB = Color(hue: 0.47, saturation: 0.78, brightness: 0.75) // refined teal - elegant
    private static let masculineAccentC = Color(hue: 0.60, saturation: 0.68, brightness: 0.62) // deep slate blue - elegant
    private static let masculineAccentD = Color(hue: 0.51, saturation: 0.70, brightness: 0.70) // steel blue - elegant
    private static let masculineAccentE = Color(hue: 0.44, saturation: 0.75, brightness: 0.73) // emerald teal - elegant
    
    // Dynamic colors based on current theme
    static var accentA: Color {
        switch currentTheme {
        case .feminine: return feminineAccentA
        case .masculine: return masculineAccentA
        }
    }
    
    static var accentB: Color {
        switch currentTheme {
        case .feminine: return feminineAccentB
        case .masculine: return masculineAccentB
        }
    }
    
    static var accentC: Color {
        switch currentTheme {
        case .feminine: return feminineAccentC
        case .masculine: return masculineAccentC
        }
    }

    // Adaptive text colors that work on both light and dark backgrounds
    static var textPrimary: Color { 
        Color.primary
    }
    static var textSecondary: Color { 
        Color.secondary
    }
    
    // High contrast text colors for better accessibility
    static var textHighContrast: Color {
        Color.primary.opacity(0.95)
    }
    
    // For specific cases where we need white text (like on colored backgrounds)
    static var textOnAccent: Color { .white.opacity(0.98) }
    
    // For text on dark/colored backgrounds - always use white
    static var textOnDark: Color { .white.opacity(0.95) }
    
    // For secondary text on dark/colored backgrounds
    static var textSecondaryOnDark: Color { .white.opacity(0.8) }

    // MARK: - Neutral Colors (Sophisticated Grayscale)
    
    // Neutral tones for balance and versatility
    static var neutral50: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.95, alpha: 1.0)
            : UIColor(white: 0.98, alpha: 1.0)
        })
    }
    
    static var neutral100: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.90, alpha: 1.0)
            : UIColor(white: 0.95, alpha: 1.0)
        })
    }
    
    static var neutral200: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.80, alpha: 1.0)
            : UIColor(white: 0.88, alpha: 1.0)
        })
    }
    
    static var neutral300: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.65, alpha: 1.0)
            : UIColor(white: 0.75, alpha: 1.0)
        })
    }
    
    static var neutral400: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.50, alpha: 1.0)
            : UIColor(white: 0.60, alpha: 1.0)
        })
    }
    
    static var neutral500: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.40, alpha: 1.0)
            : UIColor(white: 0.45, alpha: 1.0)
        })
    }
    
    static var neutral600: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.30, alpha: 1.0)
            : UIColor(white: 0.35, alpha: 1.0)
        })
    }
    
    // Strokes & Shadows (Refined for elegant depth)
    static var strokeOuter: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.20)
            : UIColor(white: 1.0, alpha: 0.40)
        })
    }
    
    static var strokeInner: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.60)
            : UIColor(white: 1.0, alpha: 0.80)
        })
    }
    
    static var shadow: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.0, alpha: 0.60)
            : UIColor(white: 0.0, alpha: 0.35)
        })
    }

    // MARK: - Enhanced Gradients and Visual Effects
    
    // Primary gradient with enhanced color depth
    static var accentGradient: LinearGradient {
        switch currentTheme {
        case .feminine:
            return LinearGradient(
                colors: [feminineAccentA, feminineAccentB, feminineAccentC, feminineAccentD],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .masculine:
            return LinearGradient(
                colors: [masculineAccentA, masculineAccentB, masculineAccentC, masculineAccentD],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
    
    // Radial gradient for special effects
    static var accentRadialGradient: RadialGradient {
        switch currentTheme {
        case .feminine:
            return RadialGradient(
                colors: [feminineAccentA.opacity(0.8), feminineAccentB.opacity(0.6), feminineAccentC.opacity(0.4)],
                center: .center, startRadius: 0, endRadius: 200
            )
        case .masculine:
            return RadialGradient(
                colors: [masculineAccentA.opacity(0.8), masculineAccentB.opacity(0.6), masculineAccentC.opacity(0.4)],
                center: .center, startRadius: 0, endRadius: 200
            )
        }
    }
    
    // Angular gradient for premium effects
    static var accentAngularGradient: AngularGradient {
        switch currentTheme {
        case .feminine:
            return AngularGradient(
                colors: [feminineAccentA, feminineAccentB, feminineAccentC, feminineAccentD, feminineAccentA],
                center: .center, startAngle: .degrees(0), endAngle: .degrees(360)
            )
        case .masculine:
            return AngularGradient(
                colors: [masculineAccentA, masculineAccentB, masculineAccentC, masculineAccentD, masculineAccentA],
                center: .center, startAngle: .degrees(0), endAngle: .degrees(360)
            )
        }
    }
    
    // Enhanced shadow colors for elegant depth (refined for sophistication)
    static var enhancedShadow: Color {
        Color(uiColor: UIColor { tc in
            switch currentTheme {
            case .feminine:
                return tc.userInterfaceStyle == .dark
                    ? UIColor(hue: 0.75, saturation: 0.70, brightness: 0.08, alpha: 0.55)
                    : UIColor(hue: 0.75, saturation: 0.70, brightness: 0.12, alpha: 0.50)
            case .masculine:
                return tc.userInterfaceStyle == .dark
                    ? UIColor(hue: 0.54, saturation: 0.75, brightness: 0.08, alpha: 0.60)
                    : UIColor(hue: 0.54, saturation: 0.75, brightness: 0.10, alpha: 0.55)
            }
        })
    }
    
    // Refined glow effect colors (more subtle and sophisticated)
    static var glowColor: Color {
        switch currentTheme {
        case .feminine:
            return Color(hue: 0.75, saturation: 0.85, brightness: 0.95, opacity: 0.65)
        case .masculine:
            return Color(hue: 0.54, saturation: 0.88, brightness: 0.92, opacity: 0.70)
        }
    }
    
    // MARK: - Background Colors (Refined for Elegance)
    
    // Background colors with sophisticated neutral tones
    static var bgDeep: Color {
        Color(uiColor: UIColor { tc in
            switch currentTheme {
            case .feminine:
                return tc.userInterfaceStyle == .dark
                    ? UIColor(hue: 0.75, saturation: 0.45, brightness: 0.08, alpha: 1)
                    : UIColor(hue: 0.75, saturation: 0.12, brightness: 0.97, alpha: 1)
            case .masculine:
                return tc.userInterfaceStyle == .dark
                    ? UIColor(hue: 0.54, saturation: 0.50, brightness: 0.08, alpha: 1)
                    : UIColor(hue: 0.54, saturation: 0.10, brightness: 0.97, alpha: 1)
            }
        })
    }
    
    // Secondary background for cards and elevated surfaces
    static var bgSecondary: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.12, alpha: 1.0)
            : UIColor(white: 0.98, alpha: 1.0)
        })
    }
    
    // Tertiary background for nested elements
    static var bgTertiary: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(white: 0.15, alpha: 1.0)
            : UIColor(white: 0.95, alpha: 1.0)
        })
    }
}

// NOTE: Do NOT define ThemeStore here to avoid duplicate type errors.
// Keep a single ThemeStore in one file only.
