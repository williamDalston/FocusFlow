import SwiftUI

// MARK: - Disabled State Components

/// Agent 7: Disabled state modifier for views
struct DisabledStateModifier: ViewModifier {
    let isDisabled: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isDisabled ? DesignSystem.Opacity.disabled : 1.0)
            .allowsHitTesting(!isDisabled)
            .animation(AnimationConstants.quickEase, value: isDisabled)
    }
}

extension View {
    /// Applies disabled state styling
    func disabledState(_ isDisabled: Bool) -> some View {
        modifier(DisabledStateModifier(isDisabled: isDisabled))
    }
}

/// Agent 7: Disabled button style modifier
struct DisabledButtonModifier: ViewModifier {
    let isDisabled: Bool
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity((isDisabled || isLoading) ? DesignSystem.Opacity.disabled : 1.0)
            .allowsHitTesting(!isDisabled && !isLoading)
            .animation(AnimationConstants.quickEase, value: isDisabled)
            .animation(AnimationConstants.quickEase, value: isLoading)
    }
}

extension View {
    /// Applies disabled button state
    func disabledButton(_ isDisabled: Bool, isLoading: Bool = false) -> some View {
        modifier(DisabledButtonModifier(isDisabled: isDisabled, isLoading: isLoading))
    }
}


