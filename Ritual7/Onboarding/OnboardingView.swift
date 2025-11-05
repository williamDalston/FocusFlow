import SwiftUI

/// Agent 24: Progressive Onboarding System - Enhanced with skip option and improved progressive disclosure
struct OnboardingView: View {
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var step = 0
    @State private var reminderEnabled = false
    @State private var reminderTime = DateComponents(hour: 20, minute: 0) // 8 PM default
    @State private var pendingAuth = false
    
    // Onboarding steps with progressive disclosure
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to Ritual7 👋",
            description: "Transform your life in just 7 minutes a day. Build strength, improve fitness, and create lasting habits with our science-backed workout program.",
            icon: "figure.run",
            iconColors: [Theme.accentA, Theme.accentB]
        ),
        OnboardingStep(
            title: "12 Exercises, 7 Minutes 💪",
            description: "Complete a full-body workout with 12 exercises, each lasting 30 seconds with 10-second rest periods. No equipment needed—just your commitment.",
            icon: "timer",
            iconColors: [Theme.accentB, Theme.accentC]
        ),
        OnboardingStep(
            title: "Build a Streak 🔥",
            description: "Work out daily to grow your streak. Small consistent efforts compound into big results. Track your progress and celebrate your achievements.",
            icon: "flame.fill",
            iconColors: [Theme.accentC, Theme.accentA]
        )
    ]

    var body: some View {
        ZStack {
            ThemeBackground()
            
            VStack(spacing: 0) {
                // Skip button at top (only show if not on last step)
                if step < steps.count {
                    HStack {
                        Spacer()
                        Button {
                            Haptics.tap()
                            skipOnboarding()
                        } label: {
                            Text("Skip")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textSecondaryOnDark)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                        }
                        .padding(.top, DesignSystem.Spacing.md)
                        .padding(.trailing, DesignSystem.Spacing.md)
                    }
                }
                
                TabView(selection: $step) {
                    // Welcome steps using OnboardingStepView
                    ForEach(0..<steps.count, id: \.self) { index in
                        OnboardingStepView(
                            step: steps[index],
                            isLastStep: index == steps.count - 1,
                            onNext: {
                                withAnimation(AnimationConstants.smoothSpring) {
                                    if index < steps.count - 1 {
                                        step += 1
                                    } else {
                                        step = steps.count // Move to reminders page
                                    }
                                }
                            },
                            onSkip: index < steps.count - 1 ? {
                                skipOnboarding()
                            } : nil
                        )
                        .tag(index)
                    }
                    
                    // Reminders page (last step)
                    remindersPage.tag(steps.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
    }
    
    private func skipOnboarding() {
        Haptics.tap()
        onboardingManager.completeOnboarding()
    }


    private var remindersPage: some View {
        let isIPad = horizontalSizeClass == .regular
        
        return VStack(spacing: isIPad ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl) {
            Spacer()
            
            // Title
            Text("Stay consistent")
                .font(isIPad ? Theme.largeTitle : Theme.title)
                .foregroundStyle(Theme.textOnDark)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
                .padding(.horizontal, isIPad ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl)
            
            // Description
            Text("Get a gentle daily reminder at a time you choose to help you build your workout habit.")
                .font(isIPad ? Theme.title2 : Theme.title3)
                .foregroundStyle(Theme.textSecondaryOnDark)
                .multilineTextAlignment(.center)
                .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                .padding(.horizontal, isIPad ? DesignSystem.Spacing.xxxl : DesignSystem.Spacing.xxl)
                .padding(.top, DesignSystem.Spacing.lg)
                .minimumScaleFactor(0.85)
            
            // Toggle card with consistent styling
            GlassCard(material: .ultraThinMaterial) {
                Toggle(isOn: $reminderEnabled) {
                    Label("Enable Daily Workout Reminder", systemImage: "bell.badge")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textOnDark)
                }
                .tint(Theme.accentA)
            }
            .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
            .padding(.top, DesignSystem.Spacing.xl)

            // Time picker card (conditional)
            if reminderEnabled {
                GlassCard(material: .ultraThinMaterial) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Text("Time")
                            .font(Theme.body)
                            .foregroundStyle(Theme.textOnDark)
                        Spacer()
                        DatePicker(
                            "",
                            selection: Binding(
                                get: {
                                    Calendar.current.date(from: reminderTime) ?? Date()
                                },
                                set: { date in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    reminderTime = comps
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(Theme.accentA)
                    }
                }
                .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
                .padding(.top, DesignSystem.Spacing.lg)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            // Final button with consistent styling
            Button {
                Task {
                    if reminderEnabled {
                        pendingAuth = true
                        let granted = await NotificationManager.requestAuthorization()
                        pendingAuth = false
                        if granted {
                            NotificationManager.scheduleDailyReminder(at: reminderTime)
                        }
                    }
                    Haptics.success()
                    onboardingManager.completeOnboarding()
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if pendingAuth {
                        ProgressView()
                            .tint(.black)
                    }
                    Text("Get Started")
                        .fontWeight(DesignSystem.Typography.headlineWeight)
                }
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.ButtonSize.large.height)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .disabled(pendingAuth)
            .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
            .padding(.bottom, isIPad ? DesignSystem.Spacing.xxxl : DesignSystem.Spacing.xxl)
        }
        .animation(AnimationConstants.smoothSpring, value: reminderEnabled)
    }
}

