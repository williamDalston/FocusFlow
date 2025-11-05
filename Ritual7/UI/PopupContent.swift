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
                ZStack {
                    // Base material
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Enhanced gradient overlay - different from background
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentB.opacity(0.15),
                                    Theme.accentA.opacity(0.12),
                                    Theme.accentC.opacity(0.10),
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Additional highlight layer for 3D effect
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.overlay)
                }
                .overlay(
                    // Enhanced outer border with theme gradient
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.strokeInner.opacity(DesignSystem.Opacity.veryStrong * 1.2),
                                    Theme.accentA.opacity(DesignSystem.Opacity.medium * 1.2),
                                    Theme.accentB.opacity(DesignSystem.Opacity.light * 1.1),
                                    Theme.accentC.opacity(DesignSystem.Opacity.light * 0.9),
                                    Theme.strokeInner.opacity(DesignSystem.Opacity.medium)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: borderWidth
                        )
                        .allowsHitTesting(false)
                )
                .overlay(
                    // Enhanced inner highlight for depth
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 1.5),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            ),
                            lineWidth: borderWidth * 0.6
                        )
                        .blur(radius: 1.0)
                        .allowsHitTesting(false)
                )
                .overlay(
                    // Glow effect for highlighting
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.glowColor.opacity(DesignSystem.Opacity.glow * 1.3),
                                    Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.8),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            ),
                            lineWidth: borderWidth * 0.5
                        )
                        .blur(radius: 2.0)
                        .allowsHitTesting(false)
                )
            )
            // Enhanced multi-layer shadow system for stronger 3D popup effect
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium * 1.5),
                   radius: DesignSystem.Shadow.card.radius * 1.2,
                   x: 0,
                   y: DesignSystem.Shadow.card.y * 1.3)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.light * 1.2),
                   radius: DesignSystem.Shadow.medium.radius * 1.1,
                   x: 0,
                   y: DesignSystem.Shadow.medium.y * 1.2)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle * 1.2),
                   radius: DesignSystem.Shadow.soft.radius * 1.1,
                   x: 0,
                   y: DesignSystem.Shadow.soft.y * 1.1)
            .shadow(color: Theme.accentA.opacity(0.15),
                   radius: 8,
                   x: 0,
                   y: 4)
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
                            .allowsHitTesting(false)
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
                            .allowsHitTesting(false)
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
    }
}

