import SwiftUI
import Foundation

/// Agent 24: Onboarding Manager - Manages onboarding state and contextual hints
/// Provides progressive disclosure of features and contextual help for first-time users
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    // MARK: - Onboarding State
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenFirstWorkoutTutorial") private var hasSeenFirstWorkoutTutorial = false
    @AppStorage("hasSeenWorkoutTimerHints") private var hasSeenWorkoutTimerHints = false
    @AppStorage("hasSeenHistoryHints") private var hasSeenHistoryHints = false
    @AppStorage("hasSeenCustomizationHints") private var hasSeenCustomizationHints = false
    
    // Feature-specific hints
    @AppStorage("hasSeenPauseHint") private var hasSeenPauseHint = false
    @AppStorage("hasSeenProgressHint") private var hasSeenProgressHint = false
    @AppStorage("hasSeenExerciseGuideHint") private var hasSeenExerciseGuideHint = false
    
    // MARK: - Public Properties
    
    var shouldShowOnboarding: Bool {
        !hasSeenOnboarding
    }
    
    var shouldShowFirstWorkoutTutorial: Bool {
        !hasSeenFirstWorkoutTutorial
    }
    
    // MARK: - Onboarding Completion
    
    func completeOnboarding() {
        hasSeenOnboarding = true
    }
    
    func completeFirstWorkoutTutorial() {
        hasSeenFirstWorkoutTutorial = true
    }
    
    // MARK: - Contextual Hints
    
    func shouldShowHint(for feature: OnboardingFeature) -> Bool {
        switch feature {
        case .workoutTimer:
            return !hasSeenWorkoutTimerHints
        case .history:
            return !hasSeenHistoryHints
        case .customization:
            return !hasSeenCustomizationHints
        case .pause:
            return !hasSeenPauseHint
        case .progress:
            return !hasSeenProgressHint
        case .exerciseGuide:
            return !hasSeenExerciseGuideHint
        }
    }
    
    func markHintAsSeen(for feature: OnboardingFeature) {
        switch feature {
        case .workoutTimer:
            hasSeenWorkoutTimerHints = true
        case .history:
            hasSeenHistoryHints = true
        case .customization:
            hasSeenCustomizationHints = true
        case .pause:
            hasSeenPauseHint = true
        case .progress:
            hasSeenProgressHint = true
        case .exerciseGuide:
            hasSeenExerciseGuideHint = true
        }
    }
    
    // MARK: - Reset (for testing/debugging)
    
    func resetOnboarding() {
        hasSeenOnboarding = false
        hasSeenFirstWorkoutTutorial = false
        hasSeenWorkoutTimerHints = false
        hasSeenHistoryHints = false
        hasSeenCustomizationHints = false
        hasSeenPauseHint = false
        hasSeenProgressHint = false
        hasSeenExerciseGuideHint = false
    }
}

// MARK: - Onboarding Features

enum OnboardingFeature: String, CaseIterable {
    case workoutTimer
    case history
    case customization
    case pause
    case progress
    case exerciseGuide
    
    var title: String {
        switch self {
        case .workoutTimer:
            return "Workout Timer"
        case .history:
            return "Workout History"
        case .customization:
            return "Customize Workout"
        case .pause:
            return "Pause Workout"
        case .progress:
            return "Track Progress"
        case .exerciseGuide:
            return "Exercise Guide"
        }
    }
    
    var message: String {
        switch self {
        case .workoutTimer:
            return "Watch the timer count down. Each exercise lasts 30 seconds with 10-second rest periods."
        case .history:
            return "View your workout history and track your progress over time."
        case .customization:
            return "Customize your workout by selecting exercises and adjusting settings."
        case .pause:
            return "Tap pause to take a break. You can resume anytime."
        case .progress:
            return "Track your streak and total workouts completed."
        case .exerciseGuide:
            return "Tap an exercise to see form tips and instructions."
        }
    }
    
    var icon: String {
        switch self {
        case .workoutTimer:
            return "timer"
        case .history:
            return "clock.fill"
        case .customization:
            return "slider.horizontal.3"
        case .pause:
            return "pause.circle.fill"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        case .exerciseGuide:
            return "questionmark.circle.fill"
        }
    }
}

// MARK: - Contextual Hint View

struct ContextualHintView: View {
    let feature: OnboardingFeature
    let onDismiss: () -> Void
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: feature.icon)
                    .font(Theme.title3)
                    .foregroundStyle(Theme.accentA)
                
                Text(feature.title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textOnDark)
                
                Spacer()
                
                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(Theme.title3)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            Text(feature.message)
                .font(Theme.body)
                .foregroundStyle(Theme.textSecondaryOnDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.light),
                                    Theme.accentB.opacity(DesignSystem.Opacity.subtle)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.standard
                        )
                )
        )
        .cardShadow()
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .offset(y: isVisible ? 0 : -20)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(AnimationConstants.smoothSpring) {
                isVisible = true
            }
        }
    }
    
    private func dismiss() {
        withAnimation(AnimationConstants.smoothEase) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

