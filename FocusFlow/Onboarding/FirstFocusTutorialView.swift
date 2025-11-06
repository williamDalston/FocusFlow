import SwiftUI

/// Agent 7: First Focus Tutorial View - Guides users through their first focus session
struct FirstFocusTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var showTutorial: Bool
    @State private var currentStep = 0
    
    let steps = [
        TutorialStep(
            title: "Welcome to Your First Focus Session",
            description: "You'll work in a focused 25-minute session, followed by a 5-minute break. After 4 sessions, you'll get a 15-minute long break.",
            icon: "brain.head.profile",
            tips: [
                "Find a quiet, distraction-free space",
                "Close unnecessary apps and notifications",
                "Have everything you need ready before starting"
            ]
        ),
        TutorialStep(
            title: "During the Focus Session",
            description: "Focus completely on your task. The timer will count down from 25 minutes. You can pause if needed, but try to maintain focus.",
            icon: "timer",
            tips: [
                "Resist the urge to check your phone or email",
                "If a thought comes up, write it down for later",
                "Trust the timer - let it guide your work rhythm"
            ]
        ),
        TutorialStep(
            title: "Take Your Breaks",
            description: "Use the 5-minute breaks to step away from your work. Stand up, stretch, get water, or just relax. Your brain needs this recovery time.",
            icon: "figure.walk",
            tips: [
                "Move your body during breaks",
                "Look away from your screen",
                "Don't use breaks to catch up on other work"
            ]
        ),
        TutorialStep(
            title: "You're Ready!",
            description: "Remember: the Pomodoro Technique is about sustainable productivity. Take breaks, stay focused, and track your progress!",
            icon: "checkmark.circle.fill",
            tips: [
                "Start when you're ready",
                "You can always pause or stop",
                "Good luck with your first session! 🍅"
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentStep ? Theme.accentA : .white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.top, DesignSystem.Spacing.formFieldSpacing)
                .padding(.bottom, DesignSystem.Spacing.xxl)
                
                TabView(selection: $currentStep) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        tutorialStepView(steps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button {
                            withAnimation {
                                currentStep -= 1
                            }
                            Haptics.tap()
                        } label: {
                            Text("Previous")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox).stroke(.white.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.standard))
                        }
                    }
                    
                    Button {
                        if currentStep < steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                            Haptics.tap()
                        } else {
                            showTutorial = false
                            OnboardingManager.shared.completeFirstFocusTutorial()
                            dismiss()
                            Haptics.success()
                        }
                    } label: {
                        Text(currentStep < steps.count - 1 ? "Next" : "Start Focus Session")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.black)
                            .padding(.vertical, 16)
                            .background(.white, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.cardPadding)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Skip") {
                    showTutorial = false
                    OnboardingManager.shared.completeFirstFocusTutorial()
                    dismiss()
                }
                .foregroundStyle(.white)
            }
        }
    }
    
    private func tutorialStepView(_ step: TutorialStep) -> some View {
        ScrollView {
            VStack(spacing: horizontalSizeClass == .regular ? 32 : 24) {
                // Icon
                Image(systemName: step.icon)
                    .font(.system(size: horizontalSizeClass == .regular ? 80 : 64, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(horizontalSizeClass == .regular ? DesignSystem.Spacing.cardPadding : DesignSystem.Spacing.formFieldSpacing)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large).stroke(.white.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.standard))
                
                // Title
                Text(step.title)
                    .font(horizontalSizeClass == .regular ? .largeTitle.weight(.bold) : .title.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                // Description
                Text(step.description)
                    .font(horizontalSizeClass == .regular ? .title3 : .body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                // Tips
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(step.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(Theme.title3)
                                .foregroundStyle(Theme.accentA)
                                .padding(.top, DesignSystem.Spacing.xs / 4)
                            
                            Text(tip)
                                .font(Theme.body)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                }
                .padding(DesignSystem.Spacing.cardPadding)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox).stroke(.white.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.standard))
                .padding(.horizontal, DesignSystem.Spacing.cardPadding)
                
                Spacer()
            }
            .padding(.top, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Tutorial Step Model

struct TutorialStep {
    let title: String
    let description: String
    let icon: String
    let tips: [String]
}

