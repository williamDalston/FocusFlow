import SwiftUI

/// iPad-optimized sheet presentation with proper sizing and drag support
extension View {
    /// Applies iPad-optimized sheet presentation with proper sizing
    /// - iPad: Starts at 85% height, draggable to full screen
    /// - iPhone: Full screen (unchanged)
    func iPadOptimizedSheetPresentation() -> some View {
        self
            .modifier(iPadSheetPresentationModifier())
    }
}

/// Modifier that adds iPad-optimized presentation detents
private struct iPadSheetPresentationModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationDetents(
                    horizontalSizeClass == .regular
                        ? [.fraction(0.85), .large]  // iPad: 85% or full screen (draggable)
                        : [.large]  // iPhone: full screen
                )
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.85)))
        } else {
            content
                .presentationDetents(
                    horizontalSizeClass == .regular
                        ? [.fraction(0.85), .large]  // iPad: 85% or full screen (draggable)
                        : [.large]  // iPhone: full screen
                )
                .presentationDragIndicator(.visible)
        }
    }
}

