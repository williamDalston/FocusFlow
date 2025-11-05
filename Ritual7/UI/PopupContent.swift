import SwiftUI

/// PopupContent - Wraps content with a beautiful popup effect similar to navigation highlights
/// Adds elevation, borders, and shadows to make content appear to pop up from the background
struct PopupContent<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: CGFloat
    let borderWidth: CGFloat
    
    init(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.large,
        padding: CGFloat = DesignSystem.Spacing.md,
        borderWidth: CGFloat = DesignSystem.Border.subtle,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderWidth = borderWidth
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        // Outer border with theme gradient
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.light),
                                        Theme.accentB.opacity(DesignSystem.Opacity.subtle),
                                        Theme.accentC.opacity(DesignSystem.Opacity.light * 0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: borderWidth
                            )
                    )
                    .overlay(
                        // Inner highlight for depth
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(DesignSystem.Opacity.highlight),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                ),
                                lineWidth: borderWidth * 0.5
                            )
                            .blur(radius: 0.5)
                    )
            )
            // Multi-layer shadow system for popup effect
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.2),
                   radius: DesignSystem.Shadow.card.radius,
                   y: DesignSystem.Shadow.card.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light),
                   radius: DesignSystem.Shadow.medium.radius,
                   y: DesignSystem.Shadow.medium.y)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle * 0.8),
                   radius: DesignSystem.Shadow.soft.radius,
                   y: DesignSystem.Shadow.soft.y)
    }
}

/// PopupContainer - Applies popup effect to the entire screen content
/// Adds margins and elevation to create a floating panel effect
struct PopupContainer<Content: View>: View {
    let content: Content
    let edgePadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    
    init(
        edgePadding: CGFloat = DesignSystem.Spacing.md,
        topPadding: CGFloat? = nil,
        bottomPadding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.edgePadding = edgePadding
        self.topPadding = topPadding ?? edgePadding
        self.bottomPadding = bottomPadding ?? edgePadding
    }
    
    var body: some View {
        content
            .padding(.horizontal, edgePadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        // Outer border with theme gradient
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.light * 0.8),
                                        Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.8),
                                        Theme.accentC.opacity(DesignSystem.Opacity.light * 0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: DesignSystem.Border.subtle
                            )
                    )
                    .overlay(
                        // Inner highlight for depth
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(DesignSystem.Opacity.highlight),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                ),
                                lineWidth: DesignSystem.Border.hairline
                            )
                            .blur(radius: 0.5)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge, style: .continuous))
            // Multi-layer shadow system for popup effect
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.1),
                   radius: DesignSystem.Shadow.card.radius * 1.2,
                   y: DesignSystem.Shadow.card.y * 1.2)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light * 0.9),
                   radius: DesignSystem.Shadow.medium.radius * 1.1,
                   y: DesignSystem.Shadow.medium.y * 1.1)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle * 0.9),
                   radius: DesignSystem.Shadow.soft.radius * 1.1,
                   y: DesignSystem.Shadow.soft.y * 1.1)
            .padding(.horizontal, edgePadding)
            .padding(.top, max(topPadding, 8)) // Ensure space from safe area/nav bar
            .padding(.bottom, max(bottomPadding, 8))
    }
}

