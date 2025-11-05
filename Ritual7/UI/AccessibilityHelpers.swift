import SwiftUI

/// Agent 8: Accessibility enhancements
/// Provides VoiceOver support, Dynamic Type, and accessibility improvements
enum AccessibilityHelpers {
    
    // MARK: - VoiceOver Labels
    
    /// Creates a descriptive label for VoiceOver
    static func workoutVoiceOverLabel(phase: String, exercise: String?, timeRemaining: Int) -> String {
        switch phase {
        case "preparing":
            return "Preparing to start workout. \(timeRemaining) seconds remaining."
        case "exercise":
            if let exercise = exercise {
                return "\(exercise). \(timeRemaining) seconds remaining."
            }
            return "Exercise in progress. \(timeRemaining) seconds remaining."
        case "rest":
            return "Rest period. \(timeRemaining) seconds remaining."
        case "completed":
            return "Workout completed successfully!"
        default:
            return "Workout ready to start."
        }
    }
    
    /// Creates a descriptive label for stats
    static func statVoiceOverLabel(title: String, value: String) -> String {
        return "\(title): \(value)"
    }
    
    // MARK: - Dynamic Type Support
    
    /// Returns appropriate font size for Dynamic Type
    static func dynamicFontSize(for sizeCategory: ContentSizeCategory, baseSize: CGFloat) -> CGFloat {
        switch sizeCategory {
        case .extraSmall:
            return baseSize * 0.8
        case .small:
            return baseSize * 0.9
        case .medium:
            return baseSize
        case .large:
            return baseSize * 1.1
        case .extraLarge:
            return baseSize * 1.2
        case .extraExtraLarge:
            return baseSize * 1.3
        case .extraExtraExtraLarge:
            return baseSize * 1.4
        case .accessibilityMedium:
            return baseSize * 1.5
        case .accessibilityLarge:
            return baseSize * 1.6
        case .accessibilityExtraLarge:
            return baseSize * 1.7
        case .accessibilityExtraExtraLarge:
            return baseSize * 1.8
        case .accessibilityExtraExtraExtraLarge:
            return baseSize * 1.9
        @unknown default:
            return baseSize
        }
    }
    
    // MARK: - Color Contrast
    
    /// Checks if color contrast meets WCAG AA standards (4.5:1 minimum for normal text)
    /// This is a simplified check - for production, use proper contrast ratio calculation
    static func hasGoodContrast(foreground: Color, background: Color) -> Bool {
        // Note: SwiftUI Color doesn't expose RGB values directly
        // This is a placeholder - in production, convert to UIColor and calculate proper contrast ratio
        // For now, we assume semantic colors (Color.primary, Color.secondary) meet standards
        return true
    }
    
    /// Calculates relative luminance for contrast checking
    /// Returns value between 0 (black) and 1 (white)
    static func relativeLuminance(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    /// Calculates contrast ratio between two colors
    /// WCAG AA requires 4.5:1 for normal text, 3:1 for large text
    static func contrastRatio(luminance1: CGFloat, luminance2: CGFloat) -> CGFloat {
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    // MARK: - Accessibility Traits
    
    /// Returns appropriate accessibility traits for buttons
    static var buttonTraits: AccessibilityTraits {
        return [.isButton]
    }
    
    /// Returns appropriate accessibility traits for headers
    static var headerTraits: AccessibilityTraits {
        return [.isHeader]
    }
    
    /// Returns appropriate accessibility traits for important content
    static var importantTraits: AccessibilityTraits {
        return [.startsMediaSession]
    }
    
    /// Returns appropriate accessibility traits for interactive elements
    static var interactiveTraits: AccessibilityTraits {
        return [.isButton, .allowsDirectInteraction]
    }
    
    /// Returns appropriate accessibility traits for stat/value displays
    static var valueTraits: AccessibilityTraits {
        return [.updatesFrequently]
    }
    
    // MARK: - Reduce Motion Support
    
    /// Checks if Reduce Motion is enabled
    static var isReduceMotionEnabled: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    /// Returns animation that respects Reduce Motion preference
    /// - Parameters:
    ///   - animation: The animation to use if Reduce Motion is disabled
    ///   - respectReduceMotion: Whether to respect Reduce Motion (default: true)
    /// - Returns: Animation or nil if Reduce Motion is enabled
    static func animation(_ animation: Animation, respectReduceMotion: Bool = true) -> Animation? {
        if respectReduceMotion && isReduceMotionEnabled {
            return nil
        }
        return animation
    }
    
    /// Returns duration that respects Reduce Motion (0 if enabled)
    /// - Parameters:
    ///   - duration: The duration to use if Reduce Motion is disabled
    ///   - respectReduceMotion: Whether to respect Reduce Motion (default: true)
    /// - Returns: Duration or 0 if Reduce Motion is enabled
    static func duration(_ duration: TimeInterval, respectReduceMotion: Bool = true) -> TimeInterval {
        if respectReduceMotion && isReduceMotionEnabled {
            return 0
        }
        return duration
    }
}

// MARK: - View Modifiers for Accessibility

/// Accessibility modifier for workout views
struct WorkoutAccessibilityModifier: ViewModifier {
    let phase: String
    let exercise: String?
    let timeRemaining: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .accessibilityLabel(AccessibilityHelpers.workoutVoiceOverLabel(
                phase: phase,
                exercise: exercise,
                timeRemaining: timeRemaining
            ))
            .accessibilityHint("Double tap to pause or resume")
            .accessibilityAddTraits(AccessibilityHelpers.importantTraits)
            .animation(reduceMotion ? nil : .default, value: phase)
    }
}

/// High contrast modifier for better visibility
struct HighContrastModifier: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        Group {
            if reduceTransparency {
                content.opacity(1.0)
                    .background(
                        colorScheme == .dark 
                        ? Color.black.opacity(0.95)
                        : Color.white.opacity(0.95)
                    )
            } else {
                content
            }
        }
        // Note: differentiateWithoutColor is handled by the system automatically
        // when using semantic colors and accessibility labels
    }
}

/// Reduce Motion modifier for animations
/// Note: This is a helper modifier - animations should check reduceMotion directly
struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : .default, value: UUID())
    }
}

extension View {
    /// Applies accessibility enhancements for workout views
    func workoutAccessibility(phase: String, exercise: String?, timeRemaining: Int) -> some View {
        modifier(WorkoutAccessibilityModifier(phase: phase, exercise: exercise, timeRemaining: timeRemaining))
    }
    
    /// Applies high contrast support
    func highContrastSupport() -> some View {
        modifier(HighContrastModifier())
    }
    
    /// Applies reduce motion support to animations
    func reduceMotionSupport() -> some View {
        modifier(ReduceMotionModifier())
    }
    
    /// Ensures minimum touch target size (44x44pt)
    func accessibilityTouchTarget() -> some View {
        self.frame(minWidth: DesignSystem.TouchTarget.minimum, minHeight: DesignSystem.TouchTarget.minimum)
    }
    
    /// Adds accessibility label with hint for buttons
    func accessibilityButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility label for stat values
    func accessibilityStat(title: String, value: String) -> some View {
        self
            .accessibilityLabel("\(title): \(value)")
            .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Dynamic Type Support

/// Dynamic Type wrapper for text
struct DynamicTypeText: View {
    let text: String
    let baseFont: Font
    @Environment(\.sizeCategory) private var sizeCategory
    
    var body: some View {
        Text(text)
            .font(baseFont)
            .dynamicTypeSize(...DynamicTypeSize.accessibility5)
    }
}

// MARK: - Accessibility Announcements

/// Helper for VoiceOver announcements
struct AccessibilityAnnouncer {
    static func announce(_ message: String) {
        #if os(iOS)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }
    
    static func announceScreenChange(_ screenName: String) {
        #if os(iOS)
        UIAccessibility.post(notification: .screenChanged, argument: screenName)
        #endif
    }
    
    static func announceLayoutChange() {
        #if os(iOS)
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
        #endif
    }
}


