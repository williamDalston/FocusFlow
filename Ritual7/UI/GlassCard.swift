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
                    // Base material background
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(material)
                    
                    // Subtle gradient overlay for depth
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.highlight),
                                    Theme.accentB.opacity(DesignSystem.Opacity.highlight * 0.5),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                }
            )
            .frame(maxWidth: .infinity)
            // Inner highlight with refined gradient (top layer for premium feel)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeInner.opacity(DesignSystem.Opacity.veryStrong),
                                Theme.accentA.opacity(DesignSystem.Opacity.medium),
                                Theme.accentB.opacity(DesignSystem.Opacity.light),
                                Theme.accentC.opacity(DesignSystem.Opacity.light * 0.8),
                                Theme.strokeInner.opacity(DesignSystem.Opacity.medium)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.card
                    )
            )
            // Outer stroke for definition
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.hairline
                    )
            )
            // Premium glow effect for depth
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.glowColor.opacity(DesignSystem.Opacity.glow),
                                Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.6),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        ),
                        lineWidth: DesignSystem.Border.hairline
                    )
                    .blur(radius: 1.5)
            )
            // Premium multi-layer shadow system
            .cardShadow()
    }
}

