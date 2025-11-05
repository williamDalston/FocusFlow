import SwiftUI

// MARK: - Shimmer Effect

/// Animated shimmer effect that sweeps across a view
/// Note: Renamed to avoid conflict with AnimationModifiers.ShimmerEffect
struct ShimmerEffectBasic: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                    .blendMode(.overlay)
                }
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmerBasic() -> some View {
        modifier(ShimmerEffectBasic())
    }
}

// MARK: - Breathing Animation

/// Subtle breathing/pulsing effect for emphasis
struct BreathingEffect: ViewModifier {
    @State private var isBreathing = false
    
    var intensity: CGFloat
    var duration: Double
    
    init(intensity: CGFloat = 1.05, duration: Double = 2.0) {
        self.intensity = intensity
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? intensity : 1.0)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isBreathing
            )
            .onAppear {
                isBreathing = true
            }
    }
}

extension View {
    func breathing(intensity: CGFloat = 1.05, duration: Double = 2.0) -> some View {
        modifier(BreathingEffect(intensity: intensity, duration: duration))
    }
}

// MARK: - Entrance Animations

/// Fade and slide entrance animation
struct FadeSlideIn: ViewModifier {
    @State private var isVisible = false
    
    var delay: Double
    var direction: SlideDirection
    
    enum SlideDirection {
        case up, down, left, right
        
        var offset: (x: CGFloat, y: CGFloat) {
            switch self {
            case .up: return (0, 30)
            case .down: return (0, -30)
            case .left: return (30, 0)
            case .right: return (-30, 0)
            }
        }
    }
    
    init(delay: Double = 0, direction: SlideDirection = .up) {
        self.delay = delay
        self.direction = direction
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(
                x: isVisible ? 0 : direction.offset.x,
                y: isVisible ? 0 : direction.offset.y
            )
            .onAppear {
                withAnimation(
                    Animation.spring(response: 0.6, dampingFraction: 0.8)
                        .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func fadeSlideIn(delay: Double = 0, direction: FadeSlideIn.SlideDirection = .up) -> some View {
        modifier(FadeSlideIn(delay: delay, direction: direction))
    }
}

// MARK: - Floating Particles

/// Animated floating particles/shapes in the background
struct FloatingParticles: View {
    @State private var particles: [Particle] = []
    @State private var animationPhase: CGFloat = 0
    
    struct Particle: Identifiable {
        let id = UUID()
        let startPosition: CGPoint
        var currentPosition: CGPoint
        let size: CGFloat
        let opacity: Double
        let speed: CGFloat
        let direction: Angle
        let amplitude: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    particleView(particle: particle)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                withAnimation(
                    Animation.linear(duration: 10.0)
                        .repeatForever(autoreverses: false)
                ) {
                    animationPhase = .pi * 2
                }
            }
        }
    }
    
    @ViewBuilder
    private func particleView(particle: Particle) -> some View {
        let directionRadians = particle.direction.radians
        let phaseOffset = animationPhase + particle.size
        let xOffset = cos(directionRadians) * particle.amplitude * sin(phaseOffset)
        let yOffset = sin(directionRadians) * particle.amplitude * sin(phaseOffset)
        let particleX = particle.currentPosition.x + xOffset
        let particleY = particle.currentPosition.y + yOffset
        let opacityValue = 0.3 + 0.2 * sin(animationPhase + Double(particle.id.hashValue) * 0.1)
        
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Theme.accentA.opacity(particle.opacity * 0.3),
                        Theme.accentB.opacity(particle.opacity * 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(x: particleX, y: particleY)
            .opacity(opacityValue)
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<6).map { index in
            let startX = CGFloat.random(in: 0...size.width)
            let startY = CGFloat.random(in: 0...size.height)
            return Particle(
                startPosition: CGPoint(x: startX, y: startY),
                currentPosition: CGPoint(x: startX, y: startY),
                size: CGFloat.random(in: 30...50),
                opacity: Double.random(in: 0.15...0.25),
                speed: CGFloat.random(in: 0.5...1.0),
                direction: Angle(degrees: Double(index) * 60),
                amplitude: CGFloat.random(in: 20...40)
            )
        }
    }
}

// MARK: - Animated Gradient Background

/// Animated gradient that shifts colors over time
struct AnimatedGradientBackground: View {
    @State private var phase: Double = 0
    
    var colors: [Color]
    var duration: Double
    
    init(colors: [Color] = [
        Theme.accentA.opacity(0.15),
        Theme.accentB.opacity(0.1),
        Theme.accentC.opacity(0.12),
        Theme.accentA.opacity(0.15)
    ], duration: Double = 8.0) {
        self.colors = colors
        self.duration = duration
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(
                x: 0.5 + 0.5 * cos(phase),
                y: 0.5 + 0.5 * sin(phase)
            ),
            endPoint: UnitPoint(
                x: 0.5 - 0.5 * cos(phase),
                y: 0.5 - 0.5 * sin(phase)
            )
        )
        .onAppear {
            withAnimation(
                Animation.linear(duration: duration)
                    .repeatForever(autoreverses: false)
            ) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Animated Gradient Shape

/// Shape style for animated gradient background
struct AnimatedGradientShape: ShapeStyle {
    @State private var phase: Double = 0
    
    var colors: [Color]
    var duration: Double
    
    init(colors: [Color] = [
        Theme.accentA.opacity(0.15),
        Theme.accentB.opacity(0.1),
        Theme.accentC.opacity(0.12),
        Theme.accentA.opacity(0.15)
    ], duration: Double = 8.0) {
        self.colors = colors
        self.duration = duration
        _phase = State(initialValue: 0)
    }
    
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        return LinearGradient(
            colors: colors,
            startPoint: UnitPoint(
                x: 0.5 + 0.5 * cos(phase),
                y: 0.5 + 0.5 * sin(phase)
            ),
            endPoint: UnitPoint(
                x: 0.5 - 0.5 * cos(phase),
                y: 0.5 - 0.5 * sin(phase)
            )
        )
    }
}

// MARK: - Glow Effect

/// Subtle glow effect around a view
/// Note: Renamed to avoid conflict with Effects.GlowEffect
struct GlowEffectModifier: ViewModifier {
    @State private var glowIntensity: Double = 0.3
    
    var color: Color
    var radius: CGFloat
    
    init(color: Color = Theme.accentA, radius: CGFloat = 20) {
        self.color = color
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(glowIntensity), radius: radius)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    glowIntensity = 0.6
                }
            }
    }
}

extension View {
    func glowModifier(color: Color = Theme.accentA, radius: CGFloat = 20) -> some View {
        modifier(GlowEffectModifier(color: color, radius: radius))
    }
}

// MARK: - Scale Entrance

/// Scale-based entrance animation
struct ScaleEntrance: ViewModifier {
    @State private var isVisible = false
    
    var delay: Double
    var springResponse: Double
    
    init(delay: Double = 0, springResponse: Double = 0.5) {
        self.delay = delay
        self.springResponse = springResponse
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0)
            .onAppear {
                withAnimation(
                    Animation.spring(response: springResponse, dampingFraction: 0.7)
                        .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func scaleEntrance(delay: Double = 0, springResponse: Double = 0.5) -> some View {
        modifier(ScaleEntrance(delay: delay, springResponse: springResponse))
    }
}

