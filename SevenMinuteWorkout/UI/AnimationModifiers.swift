import SwiftUI

// MARK: - Animation Modifiers for UI/UX Polish

/// Smooth spring animation for button interactions
extension View {
    func smoothSpringAnimation() -> some View {
        self.animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2), value: UUID())
    }
}

/// Pulse animation for attention-grabbing elements
struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false
    let duration: Double
    
    init(duration: Double = 1.5) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 0.9 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

/// Shimmer effect for loading states
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    
    init(duration: Double = 1.5) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 200)
                .onAppear {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
            )
            .clipped()
    }
}

/// Smooth fade transition
struct FadeTransition: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

/// Slide transition for views
struct SlideTransition: ViewModifier {
    let isVisible: Bool
    let edge: Edge
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? (isVisible ? 0 : -50) : edge == .trailing ? (isVisible ? 0 : 50) : 0,
                y: edge == .top ? (isVisible ? 0 : -50) : edge == .bottom ? (isVisible ? 0 : 50) : 0
            )
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
}

/// Bounce animation for success states
struct BounceAnimation: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { newValue in
                if newValue {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        scale = 1.2
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            scale = 1.0
                        }
                    }
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func pulse(duration: Double = 1.5) -> some View {
        modifier(PulseAnimation(duration: duration))
    }
    
    func shimmer(duration: Double = 1.5) -> some View {
        modifier(ShimmerEffect(duration: duration))
    }
    
    func fadeTransition(isVisible: Bool) -> some View {
        modifier(FadeTransition(isVisible: isVisible))
    }
    
    func slideTransition(isVisible: Bool, edge: Edge = .bottom) -> some View {
        modifier(SlideTransition(isVisible: isVisible, edge: edge))
    }
    
    func bounce(trigger: Bool) -> some View {
        modifier(BounceAnimation(trigger: trigger))
    }
}

// MARK: - Performance-Optimized Animation Constants

enum AnimationConstants {
    static let quickSpring = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let quickEase = Animation.easeInOut(duration: 0.2)
    static let smoothEase = Animation.easeInOut(duration: 0.3)
    static let longEase = Animation.easeInOut(duration: 0.5)
}


