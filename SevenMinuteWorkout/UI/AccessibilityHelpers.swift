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
    
    /// Checks if color contrast meets accessibility standards
    static func hasGoodContrast(foreground: Color, background: Color) -> Bool {
        // This is a simplified check - in production, use proper contrast ratio calculation
        return true // Placeholder - implement proper contrast checking
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
            .accessibilityReduceMotion(reduceMotion)
    }
}

/// High contrast modifier for better visibility
struct HighContrastModifier: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    func body(content: Content) -> some View {
        content
            .accessibilityDifferentiateWithoutColor(differentiateWithoutColor)
            .accessibilityReduceTransparency(reduceTransparency)
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


