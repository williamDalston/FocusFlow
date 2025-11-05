import SwiftUI

/// Agent 6 & 7: Onboarding flow with carefully polished layout, spacing, and styling
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var step = 0
    @State private var reminderEnabled = false
    @State private var reminderTime = DateComponents(hour: 20, minute: 0) // 8 PM default
    @State private var pendingAuth = false

    var body: some View {
        ZStack {
            ThemeBackground()
            TabView(selection: $step) {
                page(title: "Welcome 👋",
                     body: "Ritual7 helps you build strength and fitness in just 7 minutes. No equipment needed, just 12 exercises and your commitment.",
                     icon: "figure.run")
                    .tag(0)

                page(title: "12 Exercises, 7 Minutes 💪",
                     body: "Complete a full-body workout with 12 exercises, each lasting 30 seconds with 10-second rest periods. Perfect for busy schedules.",
                     icon: "timer")
                    .tag(1)

                page(title: "Build a streak 🔥",
                     body: "Work out daily to grow your streak. Small consistent efforts compound into big results.",
                     icon: "flame.fill")
                    .tag(2)

                remindersPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private func page(title: String, body: String, icon: String) -> some View {
        let isIPad = horizontalSizeClass == .regular
        
        return VStack(spacing: isIPad ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl) {
            Spacer()
            
            // Icon container with carefully chosen spacing and styling
            Image(systemName: icon)
                .font(.system(
                    size: isIPad ? DesignSystem.IconSize.huge * 1.25 : DesignSystem.IconSize.huge,
                    weight: .bold
                ))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Theme.accentA,
                            Theme.accentB,
                            Theme.accentC
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(isIPad ? DesignSystem.Spacing.xl : DesignSystem.Spacing.lg)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.xlarge,
                        style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.xlarge,
                        style: .continuous
                    )
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter,
                                Theme.accentA.opacity(DesignSystem.Opacity.light),
                                Theme.strokeOuter
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
                )
                .shadow(
                    color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium),
                    radius: DesignSystem.Shadow.medium.radius,
                    y: DesignSystem.Shadow.medium.y
                )
            
            // Title with proper typography hierarchy
            Text(title)
                .font(isIPad ? Theme.largeTitle : Theme.title)
                .foregroundStyle(Theme.textOnDark)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)
                .padding(.horizontal, isIPad ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl)
                .padding(.top, DesignSystem.Spacing.lg)
            
            // Body text with carefully chosen opacity and spacing
            Text(body)
                .font(isIPad ? Theme.title2 : Theme.title3)
                .foregroundStyle(Theme.textSecondaryOnDark)
                .multilineTextAlignment(.center)
                .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                .padding(.horizontal, isIPad ? DesignSystem.Spacing.xxxl : DesignSystem.Spacing.xxl)
                .padding(.top, DesignSystem.Spacing.lg)
                .minimumScaleFactor(0.85)
            
            Spacer()
            
            // Button with consistent styling
            Button {
                Haptics.tap()
                withAnimation(AnimationConstants.smoothSpring) {
                    step += 1
                }
            } label: {
                Text("Next")
                    .fontWeight(DesignSystem.Typography.headlineWeight)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.ButtonSize.large.height)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .padding(.horizontal, isIPad ? DesignSystem.Screen.sidePaddingIPad : DesignSystem.Screen.sidePadding)
            .padding(.bottom, isIPad ? DesignSystem.Spacing.xxxl : DesignSystem.Spacing.xxl)
        }
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
                    hasSeenOnboarding = true
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
