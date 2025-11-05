import SwiftUI

// Primary, elevated, with master designer polish and enhanced visual effects.
struct PrimaryProminentButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if isLoading {
                LoadingIndicator(size: 16, color: .black)
                    .transition(.opacity.combined(with: .scale))
                    .animation(AnimationConstants.smoothSpring, value: isLoading)
            }
            configuration.label
                .opacity(isLoading ? 0.7 : 1.0)
        }
            .font(.headline.weight(DesignSystem.Typography.headlineWeight))
            .padding(.vertical, DesignSystem.ButtonSize.standard.padding)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ButtonSize.standard.height)
            .opacity((!isEnabled || isLoading) ? DesignSystem.Opacity.disabled : 1.0)
            .background(
                ZStack {
                    // Premium white background with subtle texture
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(.white)
                    
                    // Refined theme-aware gradient overlay for depth
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.7 : DesignSystem.Opacity.subtle * 1.2),
                                    Theme.accentB.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.4 : DesignSystem.Opacity.subtle * 0.8),
                                    Theme.accentC.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.7 : DesignSystem.Opacity.subtle * 1.1),
                                    Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.3 : DesignSystem.Opacity.subtle * 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Subtle highlight for premium feel
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(configuration.isPressed ? 0.1 : 0.15),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                }
            )
            .foregroundStyle(.black)
            .overlay(
                // Refined border with theme colors
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.light * 0.7 : DesignSystem.Opacity.light * 1.2),
                                Theme.accentB.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.7 : DesignSystem.Opacity.subtle * 1.1),
                                Theme.accentC.opacity(configuration.isPressed ? DesignSystem.Opacity.light * 0.7 : DesignSystem.Opacity.light * 1.2),
                                Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.2 : DesignSystem.Opacity.subtle * 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: configuration.isPressed ? DesignSystem.Border.hairline : DesignSystem.Border.subtle
                    )
            )
            .overlay(
                // Premium inner glow effect
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.glowColor.opacity(configuration.isPressed ? DesignSystem.Opacity.glow * 0.5 : DesignSystem.Opacity.glow * 1.2),
                                Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.glow * 0.3 : DesignSystem.Opacity.glow * 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        ),
                        lineWidth: DesignSystem.Border.hairline * 0.8
                    )
                    .blur(radius: configuration.isPressed ? 0.3 : 0.8)
            )
            // Premium multi-layer shadow system with press state
            .shadow(color: Theme.enhancedShadow.opacity(configuration.isPressed ? DesignSystem.Opacity.light * 0.8 : DesignSystem.Opacity.medium * 1.1),
                    radius: configuration.isPressed ? DesignSystem.Shadow.pressed.radius : DesignSystem.Shadow.button.radius, 
                    y: configuration.isPressed ? DesignSystem.Shadow.pressed.y : DesignSystem.Shadow.button.y)
            .shadow(color: Theme.shadow.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.8 : DesignSystem.Opacity.light),
                    radius: configuration.isPressed ? DesignSystem.Shadow.pressed.radius * 0.7 : DesignSystem.Shadow.medium.radius * 0.9, 
                    y: configuration.isPressed ? DesignSystem.Shadow.pressed.y * 0.7 : DesignSystem.Shadow.medium.y * 0.9)
            .shadow(color: Theme.glowColor.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.3 : DesignSystem.Opacity.subtle * 0.9),
                    radius: configuration.isPressed ? DesignSystem.Shadow.pressed.radius * 0.5 : DesignSystem.Shadow.soft.radius * 0.7, 
                    y: configuration.isPressed ? DesignSystem.Shadow.pressed.y * 0.5 : DesignSystem.Shadow.soft.y * 0.7)
            // Agent 4: Disabled buttons don't animate - ensure conditional animation
            .scaleEffect((configuration.isPressed && isEnabled && !isLoading) ? 0.98 : 1.0)  // More subtle scale
            .brightness((configuration.isPressed && isEnabled && !isLoading) ? -0.015 : 0)  // More subtle brightness change
            .contentShape(Rectangle())  // Ensure entire button area is tappable
            .allowsHitTesting(isEnabled && !isLoading)  // Disable interaction when disabled or loading
            .animation((isEnabled && !isLoading) ? AnimationConstants.quickSpring : nil, value: configuration.isPressed)
            .animation(AnimationConstants.quickEase, value: isLoading)
            .onChange(of: configuration.isPressed) { pressed in
                // Sync haptics with button press animations
                if pressed && isEnabled && !isLoading {
                    Haptics.buttonPress()
                }
            }
    }
}

// Secondary glass button with master designer polish and enhanced visual effects
struct SecondaryGlassButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if isLoading {
                LoadingIndicator(size: 16, color: .white)
                    .transition(.opacity.combined(with: .scale))
                    .animation(AnimationConstants.smoothSpring, value: isLoading)
            }
            configuration.label
                .opacity(isLoading ? 0.7 : 1.0)
        }
            .font(.subheadline.weight(DesignSystem.Typography.headlineWeight))
            .padding(.vertical, DesignSystem.ButtonSize.small.padding)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ButtonSize.small.height)
            .opacity((!isEnabled || isLoading) ? DesignSystem.Opacity.disabled : 1.0)
            .background(
                ZStack {
                    // Premium glass material
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Refined theme-aware gradient overlay
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.4 : DesignSystem.Opacity.subtle * 0.8),
                                    Theme.accentB.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.25 : DesignSystem.Opacity.subtle * 0.5),
                                    Theme.accentC.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.4 : DesignSystem.Opacity.subtle * 0.8),
                                    Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.15 : DesignSystem.Opacity.subtle * 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                    
                    // Subtle highlight for depth
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(configuration.isPressed ? 0.05 : 0.12),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                // Refined border with theme colors
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(configuration.isPressed ? DesignSystem.Opacity.borderSubtle : DesignSystem.Opacity.borderSubtle * 1.5),
                                Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.strong * 0.7 : DesignSystem.Opacity.strong * 1.2),
                                Theme.accentB.opacity(configuration.isPressed ? DesignSystem.Opacity.light * 0.7 : DesignSystem.Opacity.light * 1.1),
                                Theme.strokeOuter.opacity(configuration.isPressed ? DesignSystem.Opacity.borderSubtle : DesignSystem.Opacity.borderSubtle * 1.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: configuration.isPressed ? DesignSystem.Border.subtle : DesignSystem.Border.standard
                    )
            )
            .overlay(
                // Premium inner glow effect
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.glowColor.opacity(configuration.isPressed ? DesignSystem.Opacity.glow * 0.5 : DesignSystem.Opacity.glow * 1.1),
                                Theme.accentA.opacity(configuration.isPressed ? DesignSystem.Opacity.glow * 0.3 : DesignSystem.Opacity.glow * 0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        ),
                        lineWidth: DesignSystem.Border.hairline * 0.9
                    )
                    .blur(radius: configuration.isPressed ? 0.5 : 1.0)
            )
            .foregroundStyle(.white)
            // Premium multi-layer shadow system with press state
            .shadow(color: Theme.enhancedShadow.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.8 : DesignSystem.Opacity.medium),
                    radius: configuration.isPressed ? DesignSystem.Shadow.pressed.radius * 0.8 : DesignSystem.Shadow.elevated.radius, 
                    y: configuration.isPressed ? DesignSystem.Shadow.pressed.y * 0.8 : DesignSystem.Shadow.elevated.y)
            .shadow(color: Theme.shadow.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.6 : DesignSystem.Opacity.light * 0.9),
                    radius: configuration.isPressed ? DesignSystem.Shadow.pressed.radius * 0.6 : DesignSystem.Shadow.medium.radius * 0.85, 
                    y: configuration.isPressed ? DesignSystem.Shadow.pressed.y * 0.6 : DesignSystem.Shadow.medium.y * 0.85)
            .shadow(color: Theme.glowColor.opacity(configuration.isPressed ? DesignSystem.Opacity.subtle * 0.3 : DesignSystem.Opacity.subtle * 0.8),
                    radius: configuration.isPressed ? DesignSystem.Shadow.pressed.radius * 0.4 : DesignSystem.Shadow.soft.radius * 0.6, 
                    y: configuration.isPressed ? DesignSystem.Shadow.pressed.y * 0.4 : DesignSystem.Shadow.soft.y * 0.6)
            // Agent 4: Disabled buttons don't animate - ensure conditional animation
            .scaleEffect((configuration.isPressed && isEnabled && !isLoading) ? 0.98 : 1.0)  // Consistent with primary
            .brightness((configuration.isPressed && isEnabled && !isLoading) ? -0.02 : 0)  // More subtle brightness change
            .contentShape(Rectangle())  // Ensure entire button area is tappable
            .allowsHitTesting(isEnabled && !isLoading)  // Disable interaction when disabled or loading
            .animation((isEnabled && !isLoading) ? AnimationConstants.quickSpring : nil, value: configuration.isPressed)
            .animation(AnimationConstants.quickEase, value: isLoading)
            .onChange(of: configuration.isPressed) { pressed in
                // Sync haptics with button press animations
                if pressed && isEnabled && !isLoading {
                    Haptics.buttonPress()
                }
            }
    }
}

// MARK: - Button Style Extensions for Easy Usage

extension ButtonStyle where Self == PrimaryProminentButtonStyle {
    static func primary(isEnabled: Bool = true, isLoading: Bool = false) -> PrimaryProminentButtonStyle {
        PrimaryProminentButtonStyle(isEnabled: isEnabled, isLoading: isLoading)
    }
}

extension ButtonStyle where Self == SecondaryGlassButtonStyle {
    static func secondary(isEnabled: Bool = true, isLoading: Bool = false) -> SecondaryGlassButtonStyle {
        SecondaryGlassButtonStyle(isEnabled: isEnabled, isLoading: isLoading)
    }
}
