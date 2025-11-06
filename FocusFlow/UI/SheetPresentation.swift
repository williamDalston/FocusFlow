import SwiftUI

/// Enhanced sheet presentation with smooth modal transitions and iPad optimization
struct SmoothSheetPresentation: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @ViewBuilder
    func body(content: Content) -> some View {
        let baseContent = content
            .background(
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
                .ignoresSafeArea()
            )
            .applySheetPresentationModifiers()
            .presentationDragIndicator(.visible)
            .presentationDetents(
                horizontalSizeClass == .regular
                    ? [.fraction(0.85), .large]  // iPad: 85% or full screen (draggable)
                    : [.large]  // iPhone: full screen
            )
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
        
        if #available(iOS 16.4, *) {
            baseContent
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.85)))
        } else {
            baseContent
        }
    }
}

extension View {
    /// Apply smooth sheet presentation with enhanced transitions
    func smoothSheetPresentation() -> some View {
        modifier(SmoothSheetPresentation())
    }
    
    /// Conditionally apply iOS 16.4+ sheet presentation modifiers
    @ViewBuilder
    func applySheetPresentationModifiers() -> some View {
        if #available(iOS 16.4, *) {
            self
                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(DesignSystem.CornerRadius.card)
        } else {
            self
        }
    }
}

