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
        }
        .ignoresSafeArea(.all)
    }

    // MARK: Layers

    private var animatedGradient: some View {
        // Simplified gradient for better performance
        LinearGradient(
            colors: [
                Theme.accentA.opacity(1.0),
                Theme.accentB.opacity(0.98),
                Theme.accentC.opacity(0.99),
                Theme.accentA.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .saturation(1.1)
        .brightness(0.05)
    }

    private var vignette: some View {
        // Simplified vignette for better performance
        RadialGradient(
            colors: [
                Theme.enhancedShadow.opacity(0.3),
                Theme.enhancedShadow.opacity(0.1),
                .clear
            ],
            center: .center, startRadius: 0, endRadius: 800
        )
        .blendMode(.multiply)
    }

    private var grain: some View {
        // Simplified grain for better performance
        Rectangle()
            .fill(Color.white.opacity(0.02))
            .allowsHitTesting(false)
            .blendMode(.overlay)
            .opacity(0.3)
    }
}
