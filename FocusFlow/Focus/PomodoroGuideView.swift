import SwiftUI

/// Agent 7: Pomodoro Guide View - Educational content about the Pomodoro Technique
struct PomodoroGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Header
                        headerSection
                        
                        // What is Pomodoro Technique
                        whatIsPomodoroSection
                        
                        // How it works
                        howItWorksSection
                        
                        // Benefits
                        benefitsSection
                        
                        // Tips for effective focus
                        tipsSection
                        
                        // Productivity tips
                        productivityTipsSection
                    }
                    .padding(.horizontal, horizontalSizeClass == .regular ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
                    .padding(.vertical, DesignSystem.Spacing.formFieldSpacing)
                }
            }
            .navigationTitle("Pomodoro Guide")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Haptics.tap()
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentA)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accentA, Theme.accentB],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Master the Pomodoro Technique")
                .font(Theme.title)
                .foregroundStyle(Theme.textOnDark)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - What is Pomodoro Section
    
    private var whatIsPomodoroSection: some View {
        GuideSection(
            title: "What is the Pomodoro Technique?",
            icon: "questionmark.circle.fill",
            iconColor: Theme.accentA
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("The Pomodoro Technique is a time management method developed by Francesco Cirillo in the late 1980s. The technique uses a timer to break work into intervals, traditionally 25 minutes in length, separated by short breaks.")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondaryOnDark)
                
                Text("These intervals are named 'pomodoros', the plural in English of the Italian word pomodoro (tomato), after the tomato-shaped kitchen timer Cirillo used as a university student.")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondaryOnDark)
            }
        }
    }
    
    // MARK: - How It Works Section
    
    private var howItWorksSection: some View {
        GuideSection(
            title: "How It Works",
            icon: "timer",
            iconColor: Theme.accentB
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                GuideStep(
                    number: 1,
                    title: "Focus Session",
                    description: "Work on your task for 25 minutes with complete focus. No distractions, no interruptions."
                )
                
                GuideStep(
                    number: 2,
                    title: "Short Break",
                    description: "Take a 5-minute break. Stand up, stretch, get some water, or just relax."
                )
                
                GuideStep(
                    number: 3,
                    title: "Repeat",
                    description: "Complete 3 more focus sessions with short breaks in between."
                )
                
                GuideStep(
                    number: 4,
                    title: "Long Break",
                    description: "After 4 completed sessions, take a longer 15-minute break to recharge."
                )
            }
        }
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        GuideSection(
            title: "Benefits",
            icon: "star.fill",
            iconColor: Theme.accentC
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                BenefitItem(
                    icon: "brain.head.profile",
                    title: "Improved Focus",
                    description: "The time constraint helps you stay focused and avoid distractions."
                )
                
                BenefitItem(
                    icon: "bolt.fill",
                    title: "Increased Productivity",
                    description: "Regular breaks prevent burnout and maintain consistent performance."
                )
                
                BenefitItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Better Time Awareness",
                    description: "You'll develop a better sense of how long tasks actually take."
                )
                
                BenefitItem(
                    icon: "heart.fill",
                    title: "Reduced Fatigue",
                    description: "Regular breaks help maintain energy levels throughout the day."
                )
            }
        }
    }
    
    // MARK: - Tips Section
    
    private var tipsSection: some View {
        GuideSection(
            title: "Tips for Effective Focus",
            icon: "lightbulb.fill",
            iconColor: Theme.accentA
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                TipItem(text: "Eliminate distractions: Put your phone away, close unnecessary tabs, and find a quiet space.")
                TipItem(text: "Plan your tasks: Before starting, list what you'll work on during the focus session.")
                TipItem(text: "Don't interrupt: If something comes up, write it down and handle it during your break.")
                TipItem(text: "Respect the break: Step away from your work during breaks. Your brain needs to recharge.")
                TipItem(text: "Track your progress: Use the app to see how many sessions you complete each day.")
            }
        }
    }
    
    // MARK: - Productivity Tips Section
    
    private var productivityTipsSection: some View {
        GuideSection(
            title: "Productivity Tips",
            icon: "sparkles",
            iconColor: Theme.accentB
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                TipItem(text: "Use the first session of the day to tackle your most important task.")
                TipItem(text: "During breaks, move your body. A short walk or stretch boosts energy.")
                TipItem(text: "Group similar tasks together to maintain momentum.")
                TipItem(text: "Review your progress at the end of the day to plan tomorrow.")
                TipItem(text: "Be flexible: Adjust session lengths if needed, but maintain the rhythm.")
            }
        }
    }
}

// MARK: - Guide Section

private struct GuideSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(Theme.title3)
                    .foregroundStyle(iconColor)
                
                Text(title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textOnDark)
            }
            
            content
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Guide Step

private struct GuideStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            // Number badge
            Text("\(number)")
                .font(Theme.headline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Theme.accentA)
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textOnDark)
                
                Text(description)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondaryOnDark)
            }
        }
    }
}

// MARK: - Benefit Item

private struct BenefitItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(Theme.accentA)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textOnDark)
                
                Text(description)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondaryOnDark)
            }
        }
    }
}

// MARK: - Tip Item

private struct TipItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(Theme.title3)
                .foregroundStyle(Theme.accentB)
                .padding(.top, 2)
            
            Text(text)
                .font(Theme.body)
                .foregroundStyle(Theme.textSecondaryOnDark)
        }
    }
}

