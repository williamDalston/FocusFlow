import SwiftUI

/// High-quality glassmorphism card with configurable material.
public struct GlassCard<Content: View>: View {
    public let material: Material
    public let content: () -> Content

    public init(
        material: Material = .ultraThinMaterial,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.material = material
        self.content = content
    }

    public var body: some View {
        content()
            .padding(DesignSystem.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Base material background with enhanced opacity
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(material)
                    
                    // Enhanced gradient overlay for depth - different from background
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentB.opacity(0.15), // Slightly different color from background
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
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
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
            )
            .frame(maxWidth: .infinity)
            // Enhanced inner highlight with refined gradient for 3D depth
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeInner.opacity(DesignSystem.Opacity.veryStrong * 1.2),
                                Theme.accentA.opacity(DesignSystem.Opacity.medium * 1.3),
                                Theme.accentB.opacity(DesignSystem.Opacity.light * 1.2),
                                Theme.accentC.opacity(DesignSystem.Opacity.light),
                                Theme.strokeInner.opacity(DesignSystem.Opacity.medium)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.card
                    )
                    .allowsHitTesting(false)
            )
            // Outer stroke for definition
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.8),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.hairline
                    )
                    .allowsHitTesting(false)
            )
            // Enhanced premium glow effect for depth and 3D appearance
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.glowColor.opacity(DesignSystem.Opacity.glow * 1.5),
                                Theme.accentA.opacity(DesignSystem.Opacity.glow * 1.0),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        ),
                        lineWidth: DesignSystem.Border.hairline * 1.5
                    )
                    .blur(radius: 2.5)
                    .allowsHitTesting(false)
            )
            // Enhanced multi-layer shadow system for stronger 3D effect
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

