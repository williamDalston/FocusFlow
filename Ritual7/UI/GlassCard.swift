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
                    // Fine-tuned material opacity for perfect glass effect
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentB.opacity(DesignSystem.Opacity.subtle * 1.25), // Fine-tuned for perfect glass effect
                                    Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.0),
                                    Theme.accentC.opacity(DesignSystem.Opacity.subtle * 0.83),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.8),
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
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 1.2),
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.6),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Refined inner glow for premium feel - subtle inner highlight
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(DesignSystem.Opacity.highlight * 0.8),
                                    Color.clear
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .blendMode(.overlay)
                        .opacity(0.7)
                    
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
            // Inner glow for sophisticated depth
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.glowColor.opacity(DesignSystem.Opacity.glow * 0.8),
                                Color.clear,
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.hairline
                    )
                    .blur(radius: 1.5)
                    .allowsHitTesting(false)
            )
            // Enhanced multi-layer shadow system using DesignSystem shadow extensions
            .cardShadow()
    }
}

