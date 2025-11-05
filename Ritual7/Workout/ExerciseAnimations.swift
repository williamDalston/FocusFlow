import SwiftUI

/// Agent 11: Exercise Animations - Animated exercise demonstrations and countdown animations
/// Provides visual feedback and engaging animations during workouts

// MARK: - Countdown Animation

struct CountdownAnimation: View {
    let count: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1.2
                            opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                scale = 1.0
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                opacity = 0.0
                                scale = 0.5
                            }
                        }
                    }
            } else if count == 0 {
                Text("GO!")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            scale = 1.3
                            opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                scale = 1.0
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                opacity = 0.0
                                scale = 0.5
                            }
                        }
                    }
            }
        }
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
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accentA, Theme.accentB],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animationPhase % 2 == 0 ? 1.0 : 1.1)
                .applySymbolEffect(.bounce, value: animationPhase)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animationPhase)
            
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            animationPhase += 1
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
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
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
                        .font(.system(size: 64, weight: .bold))
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
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showTransition = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
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
                        .font(.system(size: 64))
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
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .scaleEffect(scale)
                .opacity(showCelebration ? 1.0 : 0.0)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
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
    
    var body: some View {
        ZStack {
            if timeRemaining <= 3 && timeRemaining > 0 {
                CountdownAnimation(count: Int(timeRemaining))
            } else if timeRemaining <= 0 {
                CountdownAnimation(count: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

