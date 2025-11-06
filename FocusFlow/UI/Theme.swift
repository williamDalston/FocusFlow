import SwiftUI

// MARK: - Design System

/// App-wide theme: typography, colors, strokes, shadows.
enum Theme {
    
    // MARK: - Color Themes
    
    enum ColorTheme: String, CaseIterable {
        case calmFocus = "CalmFocus"
        case energeticTomato = "EnergeticTomato"
        case monochromePro = "MonochromePro"
        
        var displayName: String {
            switch self {
            case .calmFocus: return "Calm Focus"
            case .energeticTomato: return "Energetic Tomato"
            case .monochromePro: return "Monochrome Pro"
            }
        }
        
        var description: String {
            switch self {
            case .calmFocus: return "Cool, minimal – best default"
            case .energeticTomato: return "Warm, Pomodoro brand"
            case .monochromePro: return "Ultra-clean, for screenshots"
            }
        }
    }
    
    // Current theme (will be set by ThemeStore)
    static var currentTheme: ColorTheme = .calmFocus

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

    // MARK: - Enhanced Color Palettes (Three Focus Themes)
    
    // MARK: - 1) Calm Focus (cool, minimal – default)
    private static let calmFocusBackgroundStart = Color(hex: "0E172A")
    private static let calmFocusBackgroundMid = Color(hex: "132E4B")
    private static let calmFocusBackgroundEnd = Color(hex: "0A2F2E")
    private static let calmFocusSurfaceFill = Color.white.opacity(0.10)
    private static let calmFocusSurfaceBorder = Color.white.opacity(0.18)
    private static let calmFocusTextPrimary = Color(hex: "F8FAFC")
    private static let calmFocusTextSecondary = Color(hex: "C7D2FE")
    private static let calmFocusAccent = Color(hex: "22D3EE") // cyan-400
    private static let calmFocusAccentPressed = Color(hex: "06B6D4")
    private static let calmFocusRingFocus = Color(hex: "22D3EE")
    private static let calmFocusRingBreakShort = Color(hex: "34D399")
    private static let calmFocusRingBreakLong = Color(hex: "60A5FA")
    private static let calmFocusWarn = Color(hex: "F59E0B")
    private static let calmFocusError = Color(hex: "EF4444")
    
    // MARK: - 2) Energetic Tomato (warm, Pomodoro brand)
    private static let energeticTomatoBackgroundStart = Color(hex: "1A0E2B")
    private static let energeticTomatoBackgroundMid = Color(hex: "41164F")
    private static let energeticTomatoBackgroundEnd = Color(hex: "5F1133")
    private static let energeticTomatoSurfaceFill = Color.white.opacity(0.12)
    private static let energeticTomatoSurfaceBorder = Color.white.opacity(0.20)
    private static let energeticTomatoTextPrimary = Color(hex: "FFF7ED")
    private static let energeticTomatoTextSecondary = Color(hex: "FECACA")
    private static let energeticTomatoAccent = Color(hex: "F97316") // orange
    private static let energeticTomatoAccentPressed = Color(hex: "FB7185") // rose
    private static let energeticTomatoRingFocus = Color(hex: "F43F5E")
    private static let energeticTomatoRingBreakShort = Color(hex: "22C55E")
    private static let energeticTomatoRingBreakLong = Color(hex: "F59E0B")
    private static let energeticTomatoWarn = Color(hex: "F59E0B")
    private static let energeticTomatoError = Color(hex: "DC2626")
    
    // MARK: - 3) Monochrome Pro (ultra-clean)
    private static let monochromeProBackgroundStart = Color(hex: "0B0F1A")
    private static let monochromeProBackgroundEnd = Color(hex: "111827")
    private static let monochromeProSurfaceFill = Color.white.opacity(0.08)
    private static let monochromeProSurfaceBorder = Color.white.opacity(0.14)
    private static let monochromeProTextPrimary = Color(hex: "E5E7EB")
    private static let monochromeProTextSecondary = Color(hex: "9CA3AF")
    private static let monochromeProAccent = Color(hex: "A78BFA") // violet-400
    private static let monochromeProAccentPressed = Color(hex: "A78BFA").opacity(0.8)
    private static let monochromeProRingFocus = Color(hex: "A78BFA")
    private static let monochromeProRingBreakShort = Color(hex: "67E8F9")
    private static let monochromeProRingBreakLong = Color(hex: "93C5FD")
    private static let monochromeProWarn = Color(hex: "F59E0B")
    private static let monochromeProError = Color(hex: "F87171")
    
    // MARK: - Dynamic Colors Based on Current Theme
    
    // Background gradients
    static var backgroundGradient: LinearGradient {
        switch currentTheme {
        case .calmFocus:
            return LinearGradient(
                colors: [calmFocusBackgroundStart, calmFocusBackgroundMid, calmFocusBackgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .energeticTomato:
            return LinearGradient(
                colors: [energeticTomatoBackgroundStart, energeticTomatoBackgroundMid, energeticTomatoBackgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .monochromePro:
            return LinearGradient(
                colors: [monochromeProBackgroundStart, monochromeProBackgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Surface colors (for cards)
    static var surfaceFill: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusSurfaceFill
        case .energeticTomato: return energeticTomatoSurfaceFill
        case .monochromePro: return monochromeProSurfaceFill
        }
    }
    
    static var surfaceBorder: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusSurfaceBorder
        case .energeticTomato: return energeticTomatoSurfaceBorder
        case .monochromePro: return monochromeProSurfaceBorder
        }
    }
    
    // Text colors
    static var textPrimary: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusTextPrimary
        case .energeticTomato: return energeticTomatoTextPrimary
        case .monochromePro: return monochromeProTextPrimary
        }
    }
    
    static var textSecondary: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusTextSecondary
        case .energeticTomato: return energeticTomatoTextSecondary
        case .monochromePro: return monochromeProTextSecondary
        }
    }
    
    // Accent colors (for CTAs and buttons)
    static var accent: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusAccent
        case .energeticTomato: return energeticTomatoAccent
        case .monochromePro: return monochromeProAccent
        }
    }
    
    static var accentPressed: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusAccentPressed
        case .energeticTomato: return energeticTomatoAccentPressed
        case .monochromePro: return monochromeProAccentPressed
        }
    }
    
    // Semantic timer ring colors (Focus = cyan, Short break = green, Long break = blue)
    static var ringFocus: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusRingFocus
        case .energeticTomato: return energeticTomatoRingFocus
        case .monochromePro: return monochromeProRingFocus
        }
    }
    
    static var ringBreakShort: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusRingBreakShort
        case .energeticTomato: return energeticTomatoRingBreakShort
        case .monochromePro: return monochromeProRingBreakShort
        }
    }
    
    static var ringBreakLong: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusRingBreakLong
        case .energeticTomato: return energeticTomatoRingBreakLong
        case .monochromePro: return monochromeProRingBreakLong
        }
    }
    
    // Legacy compatibility (for backward compatibility during refactor)
    static var accentA: Color { accent }
    static var accentB: Color { ringBreakShort }
    static var accentC: Color { ringBreakLong }
    
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
    
    // MARK: - Semantic Colors
    
    // Error color for validation and error states
    static var error: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusError
        case .energeticTomato: return energeticTomatoError
        case .monochromePro: return monochromeProError
        }
    }
    
    // Success color for positive feedback (using short break green)
    static var success: Color {
        ringBreakShort
    }
    
    // Warning color for warnings
    static var warning: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusWarn
        case .energeticTomato: return energeticTomatoWarn
        case .monochromePro: return monochromeProWarn
        }
    }

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
    
    // Primary gradient - uses background gradient
    static var accentGradient: LinearGradient {
        backgroundGradient
    }
    
    // Gradient overlay for depth (subtle overlay effect)
    static var accentGradientOverlay: LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.15),
                ringBreakShort.opacity(0.12),
                ringBreakLong.opacity(0.10),
                Color.clear
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    
    // Radial gradient for special effects
    static var accentRadialGradient: RadialGradient {
        RadialGradient(
            colors: [
                accent.opacity(0.8),
                ringBreakShort.opacity(0.6),
                ringBreakLong.opacity(0.4),
                Color.clear
            ],
            center: .center, startRadius: 0, endRadius: 200
        )
    }
    
    // Angular gradient for premium effects
    static var accentAngularGradient: AngularGradient {
        AngularGradient(
            colors: [
                accent,
                ringBreakShort,
                ringBreakLong,
                accent
            ],
            center: .center, startAngle: .degrees(0), endAngle: .degrees(360)
        )
    }
    
    // Enhanced shadow colors for glass effect (y=10, blur=24, rgba(0,0,0,0.28) for dark)
    static var enhancedShadow: Color {
        Color.black.opacity(0.28)
    }
    
    // Refined glow effect colors
    static var glowColor: Color {
        accent.opacity(0.65)
    }
    
    // Inner glow color for premium feel
    static var innerGlowColor: Color {
        accent.opacity(0.55)
    }
    
    // Light ray color for emphasis effects
    static var lightRayColor: Color {
        accent.opacity(0.50)
    }
    
    // MARK: - Background Colors
    
    // Background colors - now using gradient backgrounds
    static var bgDeep: Color {
        switch currentTheme {
        case .calmFocus: return calmFocusBackgroundStart
        case .energeticTomato: return energeticTomatoBackgroundStart
        case .monochromePro: return monochromeProBackgroundStart
        }
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

// MARK: - Color Extension for Hex Support

extension Color {
    /// Creates a Color from a hex string (e.g., "FF5733" or "#FF5733")
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
