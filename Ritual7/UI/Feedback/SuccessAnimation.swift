import SwiftUI

// MARK: - Agent 27: Enhanced Success Animation Components

/// Success animation style
enum SuccessAnimationStyle {
    case bounce
    case scale
    case checkmark
    case sparkle
    case confetti
}

/// Enhanced success animation view with multiple styles
struct SuccessAnimationView: View {
    let style: SuccessAnimationStyle
    let message: String?
    let icon: String
    let color: Color
    @State private var animationPhase: CGFloat = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var sparklePositions: [CGPoint] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(
        style: SuccessAnimationStyle = .bounce,
        message: String? = nil,
        icon: String = "checkmark.circle.fill",
        color: Color = .green
    ) {
        self.style = style
        self.message = message
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Main icon
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.huge * 1.2, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(reduceMotion ? 1.0 : scale)
                .opacity(opacity)
                .shadow(color: color.opacity(DesignSystem.Opacity.medium), radius: 12, x: 0, y: 4)
                .overlay(
                    // Glow effect
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.IconSize.huge * 1.2, weight: .bold))
                        .foregroundStyle(color.opacity(DesignSystem.Opacity.glow))
                        .blur(radius: 8)
                        .scaleEffect(reduceMotion ? 1.0 : scale * 1.1)
                        .opacity(reduceMotion ? 0 : opacity * 0.6)
                )
            
            // Style-specific effects
            if !reduceMotion {
                switch style {
                case .sparkle:
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .offset(
                                x: cos(CGFloat(index) * .pi / 4) * 60 * animationPhase,
                                y: sin(CGFloat(index) * .pi / 4) * 60 * animationPhase
                            )
                            .opacity(1.0 - animationPhase)
                    }
                    
                case .confetti:
                    ForEach(0..<12, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill([color, .yellow, .orange, .pink].randomElement() ?? color)
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(CGFloat(index) * .pi / 6) * 80 * animationPhase,
                                y: sin(CGFloat(index) * .pi / 6) * 80 * animationPhase + 40 * animationPhase * animationPhase
                            )
                            .opacity(1.0 - animationPhase)
                            .rotationEffect(.degrees(Double(index) * 30 + Double(animationPhase) * 360))
                    }
                    
                default:
                    EmptyView()
                }
            }
        }
        .overlay(
            // Message (if provided)
            Group {
                if let message = message {
                    VStack {
                        Spacer()
                        Text(message)
                            .font(Theme.title3.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.top, DesignSystem.Spacing.xl)
                            .opacity(opacity)
                    }
                }
            }
        )
        .onAppear {
            Haptics.success()
            performAnimation()
        }
    }
    
    private func performAnimation() {
        guard !reduceMotion else {
            opacity = 1.0
            scale = 1.0
            return
        }
        
        switch style {
        case .bounce:
            // Bounce animation
            withAnimation(AnimationConstants.bouncySpring) {
                scale = 1.3
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(AnimationConstants.smoothSpring) {
                    scale = 1.0
                }
            }
            
        case .scale:
            // Scale up animation
            withAnimation(AnimationConstants.smoothSpring) {
                scale = 1.0
                opacity = 1.0
            }
            
        case .checkmark:
            // Checkmark draw animation (simulated with scale)
            withAnimation(AnimationConstants.quickEase) {
                scale = 1.0
                opacity = 1.0
            }
            
        case .sparkle:
            // Sparkle burst animation
            withAnimation(AnimationConstants.bouncySpring) {
                scale = 1.2
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(AnimationConstants.smoothSpring) {
                    scale = 1.0
                }
                withAnimation(.easeOut(duration: 0.6)) {
                    animationPhase = 1.0
                }
            }
            
        case .confetti:
            // Confetti burst animation
            withAnimation(AnimationConstants.bouncySpring) {
                scale = 1.2
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(AnimationConstants.smoothSpring) {
                    scale = 1.0
                }
                withAnimation(.easeOut(duration: 0.8)) {
                    animationPhase = 1.0
                }
            }
        }
    }
}

/// Success feedback modifier for any view
struct SuccessAnimationModifier: ViewModifier {
    let trigger: Bool
    let style: SuccessAnimationStyle
    @State private var scale: CGFloat = 1.0
    @State private var showAnimation: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(trigger: Bool, style: SuccessAnimationStyle = .bounce) {
        self.trigger = trigger
        self.style = style
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .scaleEffect(reduceMotion ? 1.0 : scale)
            
            if showAnimation && !reduceMotion {
                SuccessAnimationView(style: style)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: trigger) { newValue in
            guard newValue, !reduceMotion else { return }
            
            showAnimation = true
            Haptics.success()
            
            switch style {
            case .bounce:
                withAnimation(AnimationConstants.bouncySpring) {
                    scale = 1.15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        scale = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showAnimation = false
                    }
                }
                
            case .scale:
                withAnimation(AnimationConstants.smoothSpring) {
                    scale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        scale = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showAnimation = false
                    }
                }
                
            default:
                withAnimation(AnimationConstants.smoothSpring) {
                    scale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(AnimationConstants.smoothSpring) {
                        scale = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showAnimation = false
                    }
                }
            }
        }
    }
}

/// Success state overlay for completion screens
struct SuccessStateOverlay: View {
    let message: String
    let detailMessage: String?
    let isVisible: Bool
    let onDismiss: (() -> Void)?
    
    @State private var animationComplete = false
    
    init(
        message: String,
        detailMessage: String? = nil,
        isVisible: Bool = true,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.detailMessage = detailMessage
        self.isVisible = isVisible
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        if isVisible {
            ZStack {
                // Background
                Color.black.opacity(DesignSystem.Opacity.overlay * 0.7)
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: DesignSystem.Spacing.xl) {
                    SuccessAnimationView(style: .sparkle, message: nil)
                    
                    Text(message)
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    if let detailMessage = detailMessage {
                        Text(detailMessage)
                            .font(Theme.subheadline)
                            .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                            .multilineTextAlignment(.center)
                    }
                    
                    if let onDismiss = onDismiss {
                        Button {
                            onDismiss()
                        } label: {
                            Text("Continue")
                                .font(Theme.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(PrimaryProminentButtonStyle())
                        .padding(.top, DesignSystem.Spacing.md)
                    }
                }
                .padding(DesignSystem.Spacing.xxl)
                .background(
                    GlassCard(material: .ultraThinMaterial) {
                        EmptyView()
                    }
                )
                .cardShadow()
                .padding(DesignSystem.Spacing.xxl)
                .transition(.scale.combined(with: .opacity))
            }
            .zIndex(9997)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Adds success animation feedback to a view
    func successAnimation(trigger: Bool, style: SuccessAnimationStyle = .bounce) -> some View {
        modifier(SuccessAnimationModifier(trigger: trigger, style: style))
    }
}


