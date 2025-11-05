import SwiftUI

/// Agent 11: Exercise Animations - Animated exercise demonstrations and countdown animations
/// Provides visual feedback and engaging animations during workouts

// MARK: - Countdown Animation

struct CountdownAnimation: View {
    let count: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    
    // Agent 19: Color for countdown numbers based on count value
    private var countdownColor: Color {
        switch count {
        case 3:
            return Color(hue: 0.33, saturation: 0.85, brightness: 0.90) // Green
        case 2:
            return Color(hue: 0.17, saturation: 0.85, brightness: 0.90) // Yellow
        case 1:
            return Color(hue: 0.0, saturation: 0.85, brightness: 0.90) // Red
        default:
            return .white
        }
    }
    
    var body: some View {
        ZStack {
            if count > 0 {
                Text("\(count)")
                    // Agent 19: Enhanced size for more prominence (increased from 120pt to 132pt)
                    .font(.system(size: DesignSystem.IconSize.huge * 2.0625, weight: .bold, design: .rounded)) // 132pt for countdown display
                    .foregroundStyle(
                        // Agent 19: Enhanced gradient with countdown color
                        LinearGradient(
                            colors: [
                                countdownColor,
                                countdownColor.opacity(DesignSystem.Opacity.almostOpaque)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .monospacedDigit()
                    .scaleEffect(scale)
                    .opacity(opacity)
                    // Agent 19: Enhanced glow effect for countdown numbers
                    .shadow(
                        color: countdownColor.opacity(DesignSystem.Opacity.glow * 0.9),
                        radius: 20,
                        x: 0,
                        y: 4
                    )
                    .shadow(
                        color: countdownColor.opacity(DesignSystem.Opacity.glow * 0.6),
                        radius: 30,
                        x: 0,
                        y: 6
                    )
                    .onAppear {
                        // Agent 4: Optimized animation sequence using AnimationConstants
                        withAnimation(AnimationConstants.bouncySpring) {
                            scale = 1.2
                            opacity = 1.0
                        }
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
                            withAnimation(AnimationConstants.bouncySpring) {
                                scale = 1.0
                            }
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                            withAnimation(AnimationConstants.quickEase) {
                                opacity = 0.0
                                scale = 0.5
                            }
                        }
                    }
            } else if count == 0 {
                Text("GO!")
                    // Agent 19: Enhanced size for more prominence (increased from 100pt to 120pt)
                    .font(.system(size: DesignSystem.IconSize.huge * 1.875, weight: .bold, design: .rounded)) // 120pt for "GO!" display
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    // Agent 19: Enhanced glow effect for "GO!"
                    .shadow(
                        color: Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.9),
                        radius: 24,
                        x: 0,
                        y: 4
                    )
                    .shadow(
                        color: Theme.accentB.opacity(DesignSystem.Opacity.glow * 0.7),
                        radius: 36,
                        x: 0,
                        y: 6
                    )
                    .onAppear {
                        // Agent 4: Optimized animation sequence using AnimationConstants
                        withAnimation(AnimationConstants.bouncySpring) {
                            scale = 1.3
                            opacity = 1.0
                        }
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                            withAnimation(AnimationConstants.bouncySpring) {
                                scale = 1.0
                            }
                            try? await Task.sleep(nanoseconds: 700_000_000) // 0.7s
                            withAnimation(AnimationConstants.quickEase) {
                                opacity = 0.0
                                scale = 0.5
                            }
                        }
                    }
            }
        }
        .allowsHitTesting(false)  // Allow touches to pass through to content below
    }
}

// MARK: - Exercise Demonstration Animation

struct ExerciseDemonstrationView: View {
    let exercise: Exercise
    @State private var animationPhase: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated exercise icon
            Image(systemName: exercise.icon)
                .font(.system(size: DesignSystem.IconSize.huge * 1.25, weight: .bold)) // 80pt for exercise icon
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accentA, Theme.accentB],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animationPhase % 2 == 0 ? 1.0 : 1.1)
                .applySymbolEffect(.bounce, value: animationPhase)
                .animation(AnimationConstants.smoothSpring, value: animationPhase)
            
            // Form guidance indicator
            FormGuidanceIndicator(exercise: exercise)
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        // Ensure timer is created on main thread
        // Timer.scheduledTimer already runs on the main runloop
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // Timer already runs on main thread, so we can update state directly
                self.animationPhase += 1
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Form Guidance Indicator

struct FormGuidanceIndicator: View {
    let exercise: Exercise
    @State private var showGuidance = false
    
    var body: some View {
        VStack(spacing: 8) {
            if showGuidance {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    
                    Text(formGuidanceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(AnimationConstants.smoothSpring) {
                    showGuidance = true
                }
            }
        }
    }
    
    private var formGuidanceText: String {
        switch exercise.name {
        case "Jumping Jacks":
            return "Land softly on your toes"
        case "Wall Sit":
            return "Keep back flat against wall"
        case "Push-up":
            return "Keep core engaged"
        case "Abdominal Crunch":
            return "Don't pull on your neck"
        case "Squat":
            return "Keep weight in heels"
        case "Plank":
            return "Keep body in straight line"
        case "Lunge":
            return "Keep front knee over ankle"
        default:
            return "Focus on proper form"
        }
    }
}

// MARK: - Exercise Transition Animation

struct ExerciseTransitionView: View {
    let fromExercise: Exercise?
    let toExercise: Exercise
    @State private var showTransition = false
    
    var body: some View {
        ZStack {
            if showTransition {
                VStack(spacing: 24) {
                    // New exercise icon appearing
                    Image(systemName: toExercise.icon)
                        .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                        .foregroundStyle(Theme.accentA)
                        .scaleEffect(showTransition ? 1.0 : 0.5)
                        .opacity(showTransition ? 1.0 : 0.0)
                    
                    Text(toExercise.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .opacity(showTransition ? 1.0 : 0.0)
                    
                    Text("Get ready!")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .opacity(showTransition ? 1.0 : 0.0)
                }
                .padding(DesignSystem.Spacing.xxl)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            // Agent 4: Use AnimationConstants for smooth transitions
            withAnimation(AnimationConstants.smoothSpring) {
                showTransition = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(AnimationConstants.quickEase) {
                    showTransition = false
                }
            }
        }
    }
}

// MARK: - Milestone Celebration Animation

struct MilestoneCelebrationView: View {
    let milestone: String
    @State private var showCelebration = false
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            if showCelebration {
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scale)
                        .applySymbolEffect(.bounce, value: showCelebration ? 1 : 0)
                    
                    Text(milestone)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(DesignSystem.Spacing.xxl)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .scaleEffect(scale)
                .opacity(showCelebration ? 1.0 : 0.0)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            // Agent 4: Use AnimationConstants for celebration animations
            withAnimation(AnimationConstants.bouncySpring) {
                showCelebration = true
                scale = 1.0
            }
        }
    }
}

// MARK: - Prep Countdown View

struct PrepCountdownView: View {
    let timeRemaining: TimeInterval
    @State private var countdownValue: Int = 3
    
    private var countdownCount: Int {
        guard timeRemaining > 0 && timeRemaining <= 3 else {
            return timeRemaining <= 0 ? 0 : 3
        }
        return max(1, Int(timeRemaining.rounded(.up)))
    }
    
    var body: some View {
        ZStack {
            if timeRemaining <= 3 && timeRemaining > 0 {
                CountdownAnimation(count: countdownCount)
            } else if timeRemaining <= 0 {
                CountdownAnimation(count: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)  // Allow touches to pass through - this is just a visual countdown
    }
}

// MARK: - iOS 16 Compatibility Extension

extension View {
    @ViewBuilder
    func applySymbolEffect(_ effect: SymbolEffect, value: Int) -> some View {
        if #available(iOS 17.0, *) {
            switch effect {
            case .bounce:
                self.symbolEffect(.bounce, value: value)
            }
        } else {
            self
        }
    }
}

enum SymbolEffect {
    case bounce
}

