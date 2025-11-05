import SwiftUI

// Visual effects and overlays for sophisticated depth and polish.

struct Hairline: View {
    let cornerRadius: CGFloat
    var opacity: CGFloat = 0.18
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(Color.white.opacity(opacity), lineWidth: DesignSystem.Border.hairline)
    }
}

struct InnerShine: View {
    let cornerRadius: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Theme.strokeInner.opacity(DesignSystem.Opacity.veryStrong),
                        Color.white.opacity(DesignSystem.Opacity.highlight)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: DesignSystem.Border.subtle
            )
            .blendMode(.screen)
    }
}

// Enhanced glow effect for accent elements
struct GlowEffect: View {
    let cornerRadius: CGFloat
    let color: Color
    var intensity: Double = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        color.opacity(DesignSystem.Opacity.glow * intensity),
                        color.opacity(DesignSystem.Opacity.glow * intensity * 0.6),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: DesignSystem.Border.hairline * 1.5
            )
            .blur(radius: 2.5)
    }
}

// Inner glow effect for premium feel
struct InnerGlow: View {
    let cornerRadius: CGFloat
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Theme.innerGlowColor.opacity(DesignSystem.Opacity.glow * 0.8),
                        Color.clear,
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: DesignSystem.Border.hairline
            )
            .blur(radius: 1.5)
    }
}

// Light ray effect for emphasis
struct LightRay: View {
    let angle: Angle
    let color: Color
    
    var body: some View {
        LinearGradient(
            colors: [
                color.opacity(DesignSystem.Opacity.glow * 0.6),
                Color.clear,
                color.opacity(DesignSystem.Opacity.glow * 0.4)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .rotationEffect(angle)
        .blur(radius: 3.0)
    }
}

// Enhanced border with multi-stop gradient
struct EnhancedBorder: View {
    let cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
    }
}

// A tiny helper to clamp a max readable width for any container.
struct ReadableWidth: ViewModifier {
    var max: CGFloat = 600
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: max)
            .padding(.horizontal)
    }
}

extension View {
    func readableWidth(_ max: CGFloat = 600) -> some View {
        modifier(ReadableWidth(max: max))
    }
    
    /// Apply glow effect to any view
    func glowEffect(color: Color = Theme.glowColor, intensity: Double = 1.0) -> some View {
        self.overlay(
            GlowEffect(cornerRadius: DesignSystem.CornerRadius.card, color: color, intensity: intensity)
        )
    }
    
    /// Apply inner glow effect
    func innerGlow() -> some View {
        self.overlay(
            InnerGlow(cornerRadius: DesignSystem.CornerRadius.card, color: Theme.innerGlowColor)
        )
    }
}
