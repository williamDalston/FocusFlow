import SwiftUI

// Primary, elevated, with enhanced visual effects.
struct PrimaryProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(DesignSystem.Typography.headlineWeight))
            .padding(.vertical, DesignSystem.ButtonSize.standard.padding)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ButtonSize.standard.height)
            .background(
                ZStack {
                    // Enhanced background with theme colors
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(.white)
                    
                    // Ultra-enhanced theme-aware gradient overlay
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.subtle),
                                    Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.6),
                                    Theme.accentC.opacity(DesignSystem.Opacity.subtle),
                                    Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .foregroundStyle(.black)
            .overlay(
                // Ultra-enhanced border with theme colors
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(DesignSystem.Opacity.light),
                                Theme.accentB.opacity(DesignSystem.Opacity.subtle),
                                Theme.accentC.opacity(DesignSystem.Opacity.light),
                                Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.subtle
                    )
            )
            .overlay(
                // Subtle inner glow
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(Theme.glowColor.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.subtle * 0.6)
                    .blur(radius: 0.5)
            )
            // Multi-layer shadow system
            .shadow(color: Theme.enhancedShadow.opacity(configuration.isPressed ? DesignSystem.Opacity.light : DesignSystem.Opacity.medium),
                    radius: configuration.isPressed ? 10 : DesignSystem.Shadow.button.radius, 
                    y: configuration.isPressed ? 4 : DesignSystem.Shadow.button.y)
            .shadow(color: Theme.shadow.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle : DesignSystem.Opacity.light),
                    radius: configuration.isPressed ? 6 : 14, 
                    y: configuration.isPressed ? 2 : 6)
            .shadow(color: Theme.glowColor.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.5 : DesignSystem.Opacity.light),
                    radius: configuration.isPressed ? 5 : 10, 
                    y: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AnimationConstants.quickSpring, value: configuration.isPressed)
    }
}

// Secondary glass button with enhanced visual effects
struct SecondaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(DesignSystem.Typography.headlineWeight))
            .padding(.vertical, DesignSystem.ButtonSize.small.padding)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ButtonSize.small.height)
            .background(
                ZStack {
                    // Enhanced glass material
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Ultra-enhanced theme-aware gradient overlay
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.6),
                                    Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.4),
                                    Theme.accentC.opacity(DesignSystem.Opacity.subtle * 0.6),
                                    Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                // Ultra-enhanced border with theme colors
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter,
                                Theme.accentA.opacity(DesignSystem.Opacity.strong),
                                Theme.accentB.opacity(DesignSystem.Opacity.light),
                                Theme.strokeOuter
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
            .overlay(
                // Enhanced inner glow
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(Theme.glowColor.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.subtle * 0.8)
                    .blur(radius: 0.8)
            )
            .foregroundStyle(.white)
            .shadow(color: Theme.enhancedShadow.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle : DesignSystem.Opacity.medium),
                    radius: configuration.isPressed ? 8 : DesignSystem.Shadow.elevated.radius, 
                    y: configuration.isPressed ? 3 : DesignSystem.Shadow.elevated.y)
            .shadow(color: Theme.shadow.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.75 : DesignSystem.Opacity.light * 0.8),
                    radius: configuration.isPressed ? 5 : 12, 
                    y: configuration.isPressed ? 2 : 6)
            .shadow(color: Theme.glowColor.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.5 : DesignSystem.Opacity.subtle),
                    radius: configuration.isPressed ? 4 : 8, 
                    y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AnimationConstants.quickSpring, value: configuration.isPressed)
    }
}
