import SwiftUI

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
                     body: "7-Minute Workout helps you build strength and fitness in just 7 minutes. No equipment needed, just 12 exercises and your commitment.",
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
        VStack(spacing: horizontalSizeClass == .regular ? DesignSystem.Spacing.xl : DesignSystem.Spacing.xl * 0.75) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: horizontalSizeClass == .regular ? DesignSystem.IconSize.huge * 1.25 : DesignSystem.IconSize.huge, weight: .bold))
                .foregroundStyle(.white)
                .padding(horizontalSizeClass == .regular ? DesignSystem.Spacing.xl : DesignSystem.Spacing.xl * 0.83)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large * 1.1, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large * 1.1, style: .continuous).stroke(.white.opacity(DesignSystem.Opacity.subtle * 0.9), lineWidth: DesignSystem.Border.standard))
            Text(title)
                .font(horizontalSizeClass == .regular ? Theme.largeTitle : Theme.title)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
            Text(body)
                .font(horizontalSizeClass == .regular ? Theme.title2 : Theme.title3)
                .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalSizeClass == .regular ? DesignSystem.Spacing.xxxl * 0.83 : DesignSystem.Spacing.xxl * 0.94)
                .minimumScaleFactor(0.8)
            Spacer()
            Button {
                withAnimation(AnimationConstants.smoothSpring) { step += 1 }
            } label: {
                Text("Next")
                    .fontWeight(DesignSystem.Typography.headlineWeight)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.ButtonSize.large.height)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .padding(.horizontal, horizontalSizeClass == .regular ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.xl)
            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.xxxl * 1.04 : DesignSystem.Spacing.xxxl * 0.83)
        }
    }

    private var remindersPage: some View {
        VStack(spacing: horizontalSizeClass == .regular ? DesignSystem.Spacing.xl : DesignSystem.Spacing.xl * 0.75) {
            Spacer()
            Text("Stay consistent")
                .font(horizontalSizeClass == .regular ? Theme.largeTitle : Theme.title)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
            Text("Get a gentle daily reminder at a time you choose to help you build your workout habit.")
                .font(horizontalSizeClass == .regular ? Theme.title2 : Theme.title3)
                .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalSizeClass == .regular ? DesignSystem.Spacing.xxxl * 0.83 : DesignSystem.Spacing.xxl * 0.94)
                .minimumScaleFactor(0.8)

            Toggle(isOn: $reminderEnabled) {
                Label("Enable Daily Workout Reminder", systemImage: "bell.badge")
                    .font(Theme.body)
                    .foregroundStyle(.white)
            }
            .tint(.white)
            .cardPadding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous).stroke(.white.opacity(DesignSystem.Opacity.subtle * 0.9), lineWidth: DesignSystem.Border.standard))
            .padding(.horizontal, DesignSystem.Spacing.xl)

            if reminderEnabled {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Text("Time")
                        .font(Theme.body)
                        .foregroundStyle(.white.opacity(DesignSystem.Opacity.veryStrong))
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: {
                            Calendar.current.date(from: reminderTime) ?? Date()
                        },
                        set: { date in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                            reminderTime = comps
                        }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .tint(.white)
                }
                .cardPadding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous).stroke(.white.opacity(DesignSystem.Opacity.subtle * 0.9), lineWidth: DesignSystem.Border.standard))
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            Spacer()

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
                    if pendingAuth { ProgressView() }
                    Text("Get Started")
                        .fontWeight(DesignSystem.Typography.headlineWeight)
                }
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.ButtonSize.large.height)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xxxl * 0.83)
        }
    }
}
