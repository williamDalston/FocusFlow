import SwiftUI

// MARK: - Animation Modifiers for UI/UX Polish

/// Smooth spring animation for button interactions (refined for elegance)
extension View {
    func smoothSpringAnimation() -> some View {
        self.animation(.spring(response: 0.35, dampingFraction: 0.78, blendDuration: 0.22), value: UUID())
    }
}

/// Pulse animation for attention-grabbing elements (refined for subtlety)
struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false
    let duration: Double
    
    init(duration: Double = 1.8) {  // Slightly longer for more elegant feel
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.03 : 1.0)  // More subtle scale
            .opacity(isAnimating ? 0.92 : 1.0)  // More subtle opacity change
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

/// Shimmer effect for loading states (refined for sophistication)
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    
    init(duration: Double = 1.8) {  // Slightly longer for more elegant feel
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.25),  // More subtle shimmer
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

// MARK: - Performance-Optimized Animation Constants (Refined for Elegance)

enum AnimationConstants {
    // Refined spring animations for smoother, more elegant feel
    static let quickSpring = Animation.spring(response: 0.28, dampingFraction: 0.75)  // Slightly smoother
    static let smoothSpring = Animation.spring(response: 0.42, dampingFraction: 0.82)  // More refined damping
    static let bouncySpring = Animation.spring(response: 0.52, dampingFraction: 0.65)  // Slightly refined
    static let elegantSpring = Animation.spring(response: 0.45, dampingFraction: 0.85)  // New: ultra-smooth for elegance
    
    // Refined ease animations for sophistication
    static let quickEase = Animation.easeInOut(duration: 0.22)  // Slightly longer for smoother feel
    static let smoothEase = Animation.easeInOut(duration: 0.32)  // Refined timing
    static let longEase = Animation.easeInOut(duration: 0.52)  // More elegant timing
}


