import SwiftUI

/// Agent 6: First Workout Tutorial View - Guides users through their first workout
struct FirstWorkoutTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var showTutorial: Bool
    @State private var currentStep = 0
    
    let steps = [
        TutorialStep(
            title: "Welcome to Your First Workout",
            description: "You'll complete 12 exercises, each lasting 30 seconds with 10-second rest periods.",
            icon: "figure.run",
            tips: [
                "Find a comfortable space with enough room to move",
                "Have a sturdy chair nearby for some exercises",
                "Wear comfortable clothing"
            ]
        ),
        TutorialStep(
            title: "During the Workout",
            description: "Follow the timer and exercise instructions on screen. You can pause anytime if needed.",
            icon: "timer",
            tips: [
                "Focus on proper form over speed",
                "Listen to your body and rest if needed",
                "The timer will guide you through each exercise"
            ]
        ),
        TutorialStep(
            title: "Rest Periods",
            description: "Use the 10-second rest periods to catch your breath and prepare for the next exercise.",
            icon: "wind",
            tips: [
                "Take deep breaths during rest",
                "Stay hydrated",
                "Use rest to check your form"
            ]
        ),
        TutorialStep(
            title: "You're Ready!",
            description: "Remember: form is more important than speed. Take your time and enjoy your first workout!",
            icon: "checkmark.circle.fill",
            tips: [
                "Start when you're ready",
                "You can always pause or stop",
                "Good luck! 💪"
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
                            dismiss()
                            Haptics.success()
                        }
                    } label: {
                        Text(currentStep < steps.count - 1 ? "Next" : "Start Workout")
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

struct TutorialStep {
    let title: String
    let description: String
    let icon: String
    let tips: [String]
}


