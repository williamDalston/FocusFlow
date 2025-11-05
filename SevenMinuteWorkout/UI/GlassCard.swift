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
            .background(material, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous))
            .frame(maxWidth: .infinity)
            .overlay( // Ultra-enhanced inner highlight with refined gradient
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeInner.opacity(DesignSystem.Opacity.strong),
                                Theme.accentA.opacity(DesignSystem.Opacity.light),
                                Theme.accentB.opacity(DesignSystem.Opacity.subtle),
                                Theme.accentC.opacity(DesignSystem.Opacity.subtle),
                                Theme.strokeInner.opacity(DesignSystem.Opacity.medium)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
            .overlay( // Ultra-enhanced outer stroke
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
            )
            .overlay( // Subtle glow effect
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .stroke(Theme.glowColor.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.subtle)
                    .blur(radius: 1)
            )
            // Multi-layer shadow system for depth
            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium), 
                   radius: DesignSystem.Shadow.card.radius, 
                   y: DesignSystem.Shadow.card.y)
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.medium), 
                   radius: 15, 
                   y: 6)
            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle), 
                   radius: 8, 
                   y: 3)
    }
}

