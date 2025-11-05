import SwiftUI

/// Agent 29: Landscape orientation optimizer for mobile devices
/// Provides utilities and modifiers to optimize layouts for landscape viewing
enum LandscapeOptimizer {
    
    // MARK: - Thumb Zone Constants
    
    /// Optimal thumb zone for right-handed users (bottom third of screen)
    /// For iPhone: approximately bottom 200-300pt is easily reachable
    static let thumbZoneHeight: CGFloat = 250
    
    /// Safe padding from bottom edge for primary actions
    static let bottomSafePadding: CGFloat = 20
    
    /// Optimal button height for thumb zone (44-48pt minimum per Apple HIG)
    static let thumbZoneButtonHeight: CGFloat = 56
    
    // MARK: - Landscape-Specific Constants
    
    /// Spacing adjustments for landscape orientation
    static let landscapeSpacing: CGFloat = 16
    
    /// Reduced padding for landscape to maximize content visibility
    static let landscapePadding: CGFloat = 16
    
    /// Compact timer size for landscape
    static let landscapeTimerSize: CGFloat = 180
}

// MARK: - View Extensions for Landscape Optimization

extension View {
    /// Agent 29: Optimize view for landscape orientation
    /// Adjusts spacing, padding, and layout for landscape viewing
    func landscapeOptimized() -> some View {
        self.modifier(LandscapeOptimizerModifier())
    }
    
    /// Agent 29: Position content in thumb zone (bottom third of screen)
    /// Ideal for primary action buttons
    func inThumbZone() -> some View {
        self.modifier(ThumbZoneModifier())
    }
    
    /// Agent 29: Adjust layout for landscape orientation
    func landscapeLayout() -> some View {
        self.modifier(LandscapeLayoutModifier())
    }
}

// MARK: - Landscape Optimizer Modifier

private struct LandscapeOptimizerModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, isLandscape ? LandscapeOptimizer.landscapePadding : DesignSystem.Spacing.lg)
            .padding(.vertical, isLandscape ? LandscapeOptimizer.landscapeSpacing : DesignSystem.Spacing.md)
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact
    }
}

// MARK: - Thumb Zone Modifier

private struct ThumbZoneModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
                .padding(.bottom, LandscapeOptimizer.bottomSafePadding)
        }
    }
}

// MARK: - Landscape Layout Modifier

private struct LandscapeLayoutModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    func body(content: Content) -> some View {
        Group {
            if isLandscape {
                // Landscape: Use horizontal layout
                HStack(spacing: LandscapeOptimizer.landscapeSpacing) {
                    content
                }
            } else {
                // Portrait: Use vertical layout
                VStack(spacing: DesignSystem.Spacing.md) {
                    content
                }
            }
        }
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact
    }
}

// MARK: - Landscape Detection Helper

extension EnvironmentValues {
    /// Agent 29: Helper to detect landscape orientation
    var isLandscape: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact
    }
}

