import SwiftUI

/// Enhanced sheet presentation with smooth modal transitions
struct SmoothSheetPresentation: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .presentationBackground(
                ZStack {
                    Color(UIColor.systemBackground)
                    LinearGradient(
                        colors: [
                            Theme.accentA.opacity(0.03),
                            Theme.accentB.opacity(0.02),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .presentationCornerRadius(DesignSystem.CornerRadius.card)
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
            .transition(.asymmetric(
                insertion: .move(edge: .bottom)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.96)),
                removal: .move(edge: .bottom)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.96))
            ))
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 0.2)
                    : AnimationConstants.elegantSpring,
                value: UUID()
            )
    }
}

extension View {
    /// Apply smooth sheet presentation with enhanced transitions
    func smoothSheetPresentation() -> some View {
        modifier(SmoothSheetPresentation())
    }
}

