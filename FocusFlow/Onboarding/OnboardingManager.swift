import SwiftUI
import Foundation

/// Agent 7: Onboarding Manager for Pomodoro Timer - Manages onboarding state and contextual hints
/// Provides progressive disclosure of features and contextual help for first-time users
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    // MARK: - Onboarding State
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenFirstFocusTutorial") private var hasSeenFirstFocusTutorial = false
    @AppStorage("hasSeenFocusTimerHints") private var hasSeenFocusTimerHints = false
    @AppStorage("hasSeenHistoryHints") private var hasSeenHistoryHints = false
    @AppStorage("hasSeenCustomizationHints") private var hasSeenCustomizationHints = false
    
    // Feature-specific hints
    @AppStorage("hasSeenPauseHint") private var hasSeenPauseHint = false
    @AppStorage("hasSeenProgressHint") private var hasSeenProgressHint = false
    @AppStorage("hasSeenPomodoroGuideHint") private var hasSeenPomodoroGuideHint = false
    
    // MARK: - Public Properties
    
    var shouldShowOnboarding: Bool {
        !hasSeenOnboarding
    }
    
    var shouldShowFirstFocusTutorial: Bool {
        !hasSeenFirstFocusTutorial
    }
    
    // MARK: - Onboarding Completion
    
    func completeOnboarding() {
        hasSeenOnboarding = true
    }
    
    func completeFirstFocusTutorial() {
        hasSeenFirstFocusTutorial = true
    }
    
    // MARK: - Contextual Hints
    
    func shouldShowHint(for feature: OnboardingFeature) -> Bool {
        switch feature {
        case .focusTimer:
            return !hasSeenFocusTimerHints
        case .history:
            return !hasSeenHistoryHints
        case .customization:
            return !hasSeenCustomizationHints
        case .pause:
            return !hasSeenPauseHint
        case .progress:
            return !hasSeenProgressHint
        case .pomodoroGuide:
            return !hasSeenPomodoroGuideHint
        }
    }
    
    func markHintAsSeen(for feature: OnboardingFeature) {
        switch feature {
        case .focusTimer:
            hasSeenFocusTimerHints = true
        case .history:
            hasSeenHistoryHints = true
        case .customization:
            hasSeenCustomizationHints = true
        case .pause:
            hasSeenPauseHint = true
        case .progress:
            hasSeenProgressHint = true
        case .pomodoroGuide:
            hasSeenPomodoroGuideHint = true
        }
    }
    
    // MARK: - Reset (for testing/debugging)
    
    func resetOnboarding() {
        hasSeenOnboarding = false
        hasSeenFirstFocusTutorial = false
        hasSeenFocusTimerHints = false
        hasSeenHistoryHints = false
        hasSeenCustomizationHints = false
        hasSeenPauseHint = false
        hasSeenProgressHint = false
        hasSeenPomodoroGuideHint = false
    }
}

// MARK: - Onboarding Features

enum OnboardingFeature: String, CaseIterable {
    case focusTimer
    case history
    case customization
    case pause
    case progress
    case pomodoroGuide
    
    var title: String {
        switch self {
        case .focusTimer:
            return "Focus Timer"
        case .history:
            return "Session History"
        case .customization:
            return "Customize Timer"
        case .pause:
            return "Pause Session"
        case .progress:
            return "Track Progress"
        case .pomodoroGuide:
            return "Pomodoro Guide"
        }
    }
    
    var message: String {
        switch self {
        case .focusTimer:
            return "Watch the timer count down. Focus for 25 minutes, then take a 5-minute break. After 4 sessions, enjoy a 15-minute long break."
        case .history:
            return "View your focus session history and track your progress over time."
        case .customization:
            return "Customize your timer by selecting presets and adjusting focus/break durations."
        case .pause:
            return "Tap pause to take a break. You can resume anytime."
        case .progress:
            return "Track your streak and total focus sessions completed."
        case .pomodoroGuide:
            return "Learn about the Pomodoro Technique and productivity tips."
        }
    }
    
    var icon: String {
        switch self {
        case .focusTimer:
            return "timer"
        case .history:
            return "clock.fill"
        case .customization:
            return "slider.horizontal.3"
        case .pause:
            return "pause.circle.fill"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        case .pomodoroGuide:
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


