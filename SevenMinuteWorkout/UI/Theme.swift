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

    // MARK: - Typography System (Standardized)
    
    // Typography - Dynamic Type compatible with proper weights
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
    
    // Dynamic Type support
    static func dynamicTitle(for sizeClass: UserInterfaceSizeClass?) -> Font {
        switch sizeClass {
        case .regular:
            return .system(.largeTitle, design: .rounded).weight(.bold)
        default:
            return .system(.title, design: .rounded).weight(.bold)
        }
    }
    
    // Typography helpers with line heights
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

    // MARK: - Enhanced Color Palettes (High Resolution)
    
    // Feminine Theme (Optimized for contrast and accessibility)
    private static let feminineAccentA = Color(hue: 0.76, saturation: 0.85, brightness: 0.78) // rich violet - better contrast
    private static let feminineAccentB = Color(hue: 0.60, saturation: 0.90, brightness: 0.82) // vibrant blue - better contrast
    private static let feminineAccentC = Color(hue: 0.83, saturation: 0.80, brightness: 0.75) // deep indigo - better contrast
    private static let feminineAccentD = Color(hue: 0.72, saturation: 0.75, brightness: 0.80) // soft purple - better contrast
    private static let feminineAccentE = Color(hue: 0.58, saturation: 0.85, brightness: 0.85) // light blue - better contrast
    
    // Masculine Theme (Optimized for contrast and accessibility)
    private static let masculineAccentA = Color(hue: 0.55, saturation: 0.85, brightness: 0.75) // deep ocean blue - better contrast
    private static let masculineAccentB = Color(hue: 0.48, saturation: 0.90, brightness: 0.78) // rich teal - better contrast
    private static let masculineAccentC = Color(hue: 0.62, saturation: 0.85, brightness: 0.65) // navy blue - better contrast
    private static let masculineAccentD = Color(hue: 0.52, saturation: 0.85, brightness: 0.72) // steel blue - better contrast
    private static let masculineAccentE = Color(hue: 0.45, saturation: 0.90, brightness: 0.75) // emerald teal - better contrast
    
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

    // Strokes & Shadows (Enhanced for premium depth)
    static let strokeOuter = Color.white.opacity(0.35)
    static let strokeInner = Color.white.opacity(0.75)
    static let shadow      = Color.black.opacity(0.45)

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
    
    // Enhanced shadow colors for ultra-depth
    static var enhancedShadow: Color {
        switch currentTheme {
        case .feminine:
            return Color(hue: 0.76, saturation: 0.80, brightness: 0.15, opacity: 0.6)
        case .masculine:
            return Color(hue: 0.55, saturation: 0.90, brightness: 0.10, opacity: 0.7)
        }
    }
    
    // Ultra-glow effect colors
    static var glowColor: Color {
        switch currentTheme {
        case .feminine:
            return Color(hue: 0.76, saturation: 0.95, brightness: 1.0, opacity: 0.8)
        case .masculine:
            return Color(hue: 0.55, saturation: 1.0, brightness: 0.95, opacity: 0.9)
        }
    }
    
    // Background colors
    static var bgDeep: Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor(hue: 0.70, saturation: 0.60, brightness: 0.10, alpha: 1)
            : UIColor(hue: 0.62, saturation: 0.16, brightness: 0.96, alpha: 1)
        })
    }
}

// NOTE: Do NOT define ThemeStore here to avoid duplicate type errors.
// Keep a single ThemeStore in one file only.
