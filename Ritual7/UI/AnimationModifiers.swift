import SwiftUI

// MARK: - Animation Modifiers for UI/UX Polish

/// Smooth spring animation for button interactions (refined for elegance)
extension View {
    func smoothSpringAnimation() -> some View {
        self.animation(.spring(response: 0.35, dampingFraction: 0.78, blendDuration: 0.22), value: UUID())
    }
}

/// Pulse animation for attention-grabbing elements (refined for subtlety)
/// Agent 4: Enhanced with Reduce Motion support
struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false
    let duration: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(duration: Double = 1.8) {  // Slightly longer for more elegant feel
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isAnimating ? 1.03 : 1.0))  // More subtle scale
            .opacity(reduceMotion ? 1.0 : (isAnimating ? 0.92 : 1.0))  // More subtle opacity change
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AnimationConstants.ease(duration: duration, respectReduceMotion: false).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

/// Shimmer effect for loading states (refined for sophistication)
/// Agent 4: Enhanced with Reduce Motion support
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(duration: Double = 1.8) {  // Slightly longer for more elegant feel
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if !reduceMotion {
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
                    }
                }
            )
            .clipped()
    }
}

/// Smooth fade transition
/// Agent 4: Enhanced with AnimationConstants and Reduce Motion support
struct FadeTransition: ViewModifier {
    let isVisible: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(AnimationConstants.ease(duration: 0.32, respectReduceMotion: true), value: isVisible)
    }
}

/// Slide transition for views
/// Agent 4: Enhanced with AnimationConstants and Reduce Motion support
struct SlideTransition: ViewModifier {
    let isVisible: Bool
    let edge: Edge
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: reduceMotion ? 0 : (edge == .leading ? (isVisible ? 0 : -50) : edge == .trailing ? (isVisible ? 0 : 50) : 0),
                y: reduceMotion ? 0 : (edge == .top ? (isVisible ? 0 : -50) : edge == .bottom ? (isVisible ? 0 : 50) : 0)
            )
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(AnimationConstants.smoothSpring, value: isVisible)
    }
}

/// Bounce animation for success states
/// Agent 4: Enhanced with AnimationConstants and Reduce Motion support
struct BounceAnimation: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let trigger: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : scale)
            .onChange(of: trigger) { newValue in
                guard !reduceMotion, newValue else { return }
                withAnimation(AnimationConstants.bouncySpring) {
                    scale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(AnimationConstants.bouncySpring) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Additional Animation Modifiers (Agent 4)

/// Card lift effect on press - Agent 4: Card interactions
struct CardLiftEffect: ViewModifier {
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.98 : 1.0))
            .shadow(color: .black.opacity(reduceMotion ? 0.1 : (isPressed ? 0.15 : 0.25)), 
                   radius: reduceMotion ? 8 : (isPressed ? 12 : 16), 
                   y: reduceMotion ? 4 : (isPressed ? 6 : 8))
            .animation(AnimationConstants.quickSpring, value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !reduceMotion {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

/// Staggered entrance animation for list items - Agent 4: List animations
struct StaggeredEntrance: ViewModifier {
    let index: Int
    let delay: Double
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(index: Int, delay: Double = 0.05) {
        self.index = index
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1.0 : (isVisible ? 1.0 : 0.0))
            .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 20))
            .onAppear {
                guard !reduceMotion else { return }
                let delayTime = Double(index) * delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        isVisible = true
                    }
                }
            }
    }
}

/// Shake animation for error states - Agent 4: Error animations
struct ShakeAnimation: ViewModifier {
    let trigger: Bool
    @State private var offset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .offset(x: reduceMotion ? 0 : offset)
            .onChange(of: trigger) { newValue in
                guard !reduceMotion, newValue else { return }
                withAnimation(AnimationConstants.quickSpring) {
                    offset = -10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(AnimationConstants.quickSpring) {
                        offset = 10
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(AnimationConstants.quickSpring) {
                        offset = -5
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(AnimationConstants.quickSpring) {
                        offset = 0
                    }
                }
            }
    }
}

/// Loading spinner animation - Agent 4: Loading states
struct LoadingSpinner: ViewModifier {
    @State private var rotation: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(reduceMotion ? 0 : rotation))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotation = 360
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
    
    /// Agent 4: Card lift effect
    func cardLift() -> some View {
        modifier(CardLiftEffect())
    }
    
    /// Agent 4: Staggered entrance animation
    func staggeredEntrance(index: Int, delay: Double = 0.05) -> some View {
        modifier(StaggeredEntrance(index: index, delay: delay))
    }
    
    /// Agent 4: Shake animation for errors
    func shake(trigger: Bool) -> some View {
        modifier(ShakeAnimation(trigger: trigger))
    }
    
    /// Agent 4: Loading spinner
    func loadingSpinner() -> some View {
        modifier(LoadingSpinner())
    }
}

// MARK: - Performance-Optimized Animation Constants (Refined for Elegance)
// Agent 4: Enhanced animation system with Reduce Motion support and refined parameters

enum AnimationConstants {
    // Refined spring animations for natural feel (response: 0.35-0.45, damping: 0.75-0.85)
    static let quickSpring = Animation.spring(response: 0.35, dampingFraction: 0.75)  // Quick interactions
    static let smoothSpring = Animation.spring(response: 0.40, dampingFraction: 0.80)  // Standard smooth animations
    static let bouncySpring = Animation.spring(response: 0.45, dampingFraction: 0.70)  // Playful bounces
    static let elegantSpring = Animation.spring(response: 0.42, dampingFraction: 0.85)  // Ultra-smooth for elegance
    
    // Standardized ease animations (0.22s, 0.32s, 0.52s)
    static let quickEase = Animation.easeInOut(duration: 0.22)  // Quick transitions
    static let smoothEase = Animation.easeInOut(duration: 0.32)  // Standard transitions
    static let longEase = Animation.easeInOut(duration: 0.52)  // Longer transitions
    
    // Linear animations for progress indicators
    static let progressLinear = Animation.linear(duration: 0.1)  // Smooth progress updates
    
    // Helper to get animation respecting Reduce Motion
    static func animation(_ animation: Animation, respectReduceMotion: Bool = true) -> Animation? {
        if respectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return nil  // Disable animations when Reduce Motion is enabled
        }
        return animation
    }
    
    // Helper to conditionally apply animation
    static func spring(response: Double, dampingFraction: Double, respectReduceMotion: Bool = true) -> Animation {
        if respectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return Animation.linear(duration: 0)
        }
        return Animation.spring(response: response, dampingFraction: dampingFraction)
    }
    
    static func ease(duration: Double, respectReduceMotion: Bool = true) -> Animation {
        if respectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return Animation.linear(duration: 0)
        }
        return Animation.easeInOut(duration: duration)
    }
}


