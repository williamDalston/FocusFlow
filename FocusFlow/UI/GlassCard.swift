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
                        .opacity(0.98)  // Slightly increased for more presence
                    
                    // Enhanced gradient overlay with refined color stops for depth
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentB.opacity(DesignSystem.Opacity.subtle * 1.3),
                                    Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.1),
                                    Theme.accentC.opacity(DesignSystem.Opacity.subtle * 0.9),
                                    Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.7),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.9),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.6),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Enhanced highlight layer with refined gradient for 3D effect
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 1.3),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.9),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.6),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Enhanced inner glow with refined radial gradient for premium feel
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 1.0),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.6),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.3),
                                    Color.clear
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 140
                            )
                        )
                        .blendMode(.overlay)
                        .opacity(0.75)
                    
                    // Subtle reflection effect for premium glass feel
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 1.2),
                                    Color.clear,
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                        .opacity(0.5)
                }
            )
            .frame(maxWidth: .infinity)
            // Enhanced inner highlight with refined multi-stop gradient for 3D depth
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeInner.opacity(DesignSystem.Opacity.veryStrong * 1.3),
                                Theme.accentA.opacity(DesignSystem.Opacity.medium * 1.4),
                                Theme.accentB.opacity(DesignSystem.Opacity.medium * 1.1),
                                Theme.accentC.opacity(DesignSystem.Opacity.light * 1.2),
                                Theme.accentA.opacity(DesignSystem.Opacity.light * 0.8),
                                Theme.strokeInner.opacity(DesignSystem.Opacity.medium * 1.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.card
                    )
                    .allowsHitTesting(false)
            )
            // Outer stroke with sophisticated gradient for definition
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 2.0),
                                Theme.accentA.opacity(DesignSystem.Opacity.light * 0.3),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2),
                                Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.4),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.hairline
                    )
                    .allowsHitTesting(false)
            )
            // Enhanced glow effect with refined gradient
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.glowColor.opacity(DesignSystem.Opacity.glow * 0.8),
                                Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.5),
                                Theme.accentB.opacity(DesignSystem.Opacity.glow * 0.3),
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
            // Enhanced multi-layer shadow system using DesignSystem shadow extensions
            .cardShadow()
    }
}

