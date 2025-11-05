import SwiftUI

/// Premium animated background with subtle grain.
/// Light on GPU; respects Reduce Motion.
struct ThemeBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            animatedGradient
            vignette
            grain
            depthOfField
        }
        .ignoresSafeArea(.all)
        .allowsHitTesting(false)  // Allow touches to pass through to content above
    }

    // MARK: Layers

    private var animatedGradient: some View {
        // Refined gradient with sophisticated color transitions
        LinearGradient(
            colors: [
                Theme.accentA.opacity(0.98),
                Theme.accentB.opacity(0.96),
                Theme.accentC.opacity(0.97),
                Theme.accentA.opacity(0.95),
                Theme.accentC.opacity(0.94)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .saturation(1.05)  // Slightly reduced for more sophisticated look
        .brightness(0.03)  // More subtle brightness adjustment
    }

    private var vignette: some View {
        // Refined vignette with more subtle, elegant depth
        RadialGradient(
            colors: [
                Theme.enhancedShadow.opacity(0.25),  // More subtle
                Theme.enhancedShadow.opacity(0.12),  // Refined middle stop
                Theme.enhancedShadow.opacity(0.08),  // More refined
                .clear
            ],
            center: .center, startRadius: 0, endRadius: 1200  // Larger radius for softer effect
        )
        .blendMode(.multiply)
    }

    private var grain: some View {
        // Refined grain texture for subtle sophistication
        Rectangle()
            .fill(
                // Subtle grain pattern using noise-like effect
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.015),
                        Color.white.opacity(0.008),
                        Color.white.opacity(0.015)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .allowsHitTesting(false)
            .blendMode(.overlay)
            .opacity(0.25)  // More refined opacity
    }
    
    private var depthOfField: some View {
        // Subtle depth of field effect for visual depth
        RadialGradient(
            colors: [
                Theme.accentA.opacity(0.06),
                Color.clear,
                Theme.accentC.opacity(0.04)
            ],
            center: .topTrailing,
            startRadius: 0,
            endRadius: 800
        )
        .blendMode(.softLight)
        .opacity(0.6)
    }
}
