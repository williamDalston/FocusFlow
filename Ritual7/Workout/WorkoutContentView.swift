import SwiftUI

/// Main workout content view - displays workout information and controls
struct WorkoutContentView: View {
    @EnvironmentObject private var store: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var engine = WorkoutEngine()
    
    @State private var showTimerView = false
    @State private var showExerciseList = false
    @State private var showHistory = false
    @State private var showCustomization = false
    @State private var showAnalytics = false
    @State private var showAchievements = false
    @State private var showInsights = false
    @StateObject private var messageManager = MotivationalMessageManager.shared
    @State private var showAchievementCelebration: AchievementNotifier.Achievement? = nil
    
    // Agent 2: Analytics - Use lazy initialization to get store from environment
    @State private var analytics: WorkoutAnalytics?
    @State private var achievementManager: AchievementManager?
    
    // Agent 10: Goals - Goal management system
    @State private var goalManager: GoalManager?
    @State private var showGoals = false
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing) {
                        header
                        dailyQuoteCard
                        quickStartCard
                        statsGrid
                        
                        // Agent 2: Recent Achievements
                        if let manager = achievementManager, !manager.recentUnlocks.isEmpty {
                            RecentAchievementsView(achievementManager: manager)
                        }
                        
                        // Agent 2: Quick Insights
                        if analytics != nil {
                            quickInsightsSection
                        }
                        
                        // Agent 10: Goals Section
                        if let goalManager = goalManager {
                            goalsSection(goalManager: goalManager)
                        }
                        
                        exerciseListPreview
                        recentWorkouts
                        Spacer(minLength: horizontalSizeClass == .regular ? 300 : 200)
                    }
                    .padding(.top, horizontalSizeClass == .regular ? DesignSystem.Spacing.xl : DesignSystem.Spacing.md)
                    .padding(.horizontal, horizontalSizeClass == .regular ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.lg)
                    .frame(maxWidth: horizontalSizeClass == .regular ? DesignSystem.Screen.maxContentWidth : .infinity)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .sheet(isPresented: $showTimerView) {
            NavigationStack {
                WorkoutTimerView(engine: engine, store: store)
            }
            .interactiveDismissDisabled(engine.phase != .idle && engine.phase != .completed)
            .onAppear {
                // Ensure engine is ready
                if engine.phase == .completed {
                    engine.reset()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StartWorkoutFromShortcut"))) { _ in
            // Agent 8: Handle shortcut-triggered workout start
            engine.stop()
            showTimerView = true
        }
        .sheet(isPresented: $showExerciseList) {
            NavigationStack {
                ExerciseListView()
            }
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                WorkoutHistoryView()
                    .environmentObject(store)
            }
        }
        .sheet(isPresented: $showCustomization) {
            WorkoutCustomizationView()
                .environmentObject(preferencesStore)
        }
        .sheet(item: $showAchievementCelebration) { achievement in
            AchievementCelebrationView(achievement: achievement)
        }
        .sheet(isPresented: $showAnalytics) {
            if let analytics = analytics, let manager = achievementManager {
                NavigationStack {
                    AnalyticsMainView()
                        .environmentObject(store)
                        .environmentObject(analytics)
                        .environmentObject(manager)
                }
            }
        }
        .sheet(isPresented: $showAchievements) {
            if let manager = achievementManager {
                NavigationStack {
                    AchievementsView(achievementManager: manager)
                }
            }
        }
        .sheet(isPresented: $showInsights) {
            if let analytics = analytics {
                NavigationStack {
                    InsightsView(analytics: analytics)
                }
            }
        }
        .sheet(isPresented: $showGoals) {
            if let goalManager = goalManager {
                NavigationStack {
                    GoalSettingView(goalManager: goalManager)
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: theme.colorTheme)
        .onAppear {
            // Initialize analytics with current store
            if analytics == nil {
                analytics = WorkoutAnalytics(store: store)
            }
            if achievementManager == nil {
                achievementManager = AchievementManager(store: store)
            }
            // Agent 10: Initialize goal manager
            if goalManager == nil {
                goalManager = GoalManager(store: store)
            }
            
            // Check achievements
            achievementManager?.checkAchievements()
            
            // Agent 10: Update goal progress
            goalManager?.updateProgress()
            
            // Load personalized message
            messageManager.personalizedMessage = messageManager.getPersonalizedMessage(
                streak: store.streak,
                totalWorkouts: store.totalWorkouts,
                workoutsThisWeek: store.workoutsThisWeek
            )
        }
    }
    
    // MARK: - Daily Quote Card
    
    private var dailyQuoteCard: some View {
        DailyQuoteView()
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(greeting())
                        .font(Theme.footnote.smallCaps())
                        .foregroundStyle(.secondary)
                        .tracking(DesignSystem.Typography.uppercaseTracking)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Ritual7")
                        .font(horizontalSizeClass == .regular ? Theme.largeTitle : Theme.title)
                        .foregroundStyle(Theme.textPrimary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: DesignSystem.Spacing.lg) {
                StreakCelebrationView(streak: store.streak)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let personalizedMessage = messageManager.personalizedMessage {
                    MotivationalMessageCard(
                        message: personalizedMessage,
                        icon: store.streak >= 7 ? "flame.fill" : "star.fill",
                        color: store.streak >= 7 ? .orange : Theme.accentA
                    )
                } else {
                    HStack(spacing: DesignSystem.Spacing.xs * 0.75) {
                        Circle()
                            .fill(Theme.accentA)
                            .frame(width: DesignSystem.Spacing.sm, height: DesignSystem.Spacing.sm)
                        Circle()
                            .fill(Theme.accentB)
                            .frame(width: DesignSystem.Spacing.sm, height: DesignSystem.Spacing.sm)
                        Circle()
                            .fill(Theme.accentC)
                            .frame(width: DesignSystem.Spacing.sm, height: DesignSystem.Spacing.sm)
                    }
                    .opacity(DesignSystem.Opacity.veryStrong)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                    Theme.accentA.opacity(DesignSystem.Opacity.light * 0.4),
                                    Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.subtle
                        )
                )
            )
            .softShadow()
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Quick Start Card
    
    private var quickStartCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accentA)
                    
                    Text("Ready to Work Out?")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("12 exercises • 7 minutes • No equipment needed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    // Configure engine from preferences before starting
                    configureEngineFromPreferences()
                    // Reset engine before starting
                    engine.stop()
                    showTimerView = true
                    Haptics.tap()
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .disabled(engine.phase != .idle && engine.phase != .completed)
                
                HStack(spacing: 16) {
                    Button {
                        showCustomization = true
                        Haptics.tap()
                    } label: {
                        Label("Customize", systemImage: "slider.horizontal.3")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    
                    Button {
                        showExerciseList = true
                        Haptics.tap()
                    } label: {
                        Label("View Exercises", systemImage: "list.bullet")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    
                    Button {
                        showHistory = true
                        Haptics.tap()
                    } label: {
                        Label("History", systemImage: "clock")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Your Progress")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.gridSpacing) {
                StatBox(
                    title: "Total Workouts",
                    value: "\(store.totalWorkouts)",
                    icon: "figure.run",
                    color: Theme.accentA
                )
                
                StatBox(
                    title: "This Week",
                    value: "\(store.workoutsThisWeek)",
                    icon: "calendar",
                    color: Theme.accentB
                )
                
                StatBox(
                    title: "This Month",
                    value: "\(store.workoutsThisMonth)",
                    icon: "chart.bar.fill",
                    color: Theme.accentC
                )
                
                StatBox(
                    title: "Total Minutes",
                    value: "\(Int(store.totalMinutes))",
                    icon: "clock.fill",
                    color: Theme.accentA
                )
            }
        }
    }
    
    // MARK: - Exercise List Preview
    
    private var exerciseListPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Exercises")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    showExerciseList = true
                    Haptics.tap()
                } label: {
                    Text("View All")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(Exercise.sevenMinuteWorkout.prefix(6)) { exercise in
                        ExercisePreviewCard(exercise: exercise)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
            }
        }
    }
    
    // MARK: - Recent Workouts
    
    private var recentWorkouts: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Recent Workouts")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    showHistory = true
                    Haptics.tap()
                } label: {
                    Text("View All")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            if store.sessions.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Complete your first workout to see history here.")
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.overlay)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                    )
                )
                .softShadow()
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(store.sessions.prefix(5)) { session in
                        WorkoutHistoryRow(session: session)
                    }
                }
            }
        }
    }
    
    // MARK: - Agent 2: Quick Insights Section
    
    @ViewBuilder
    private var quickInsightsSection: some View {
        if let analytics = analytics {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Text("Insights")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        showInsights = true
                        Haptics.tap()
                    } label: {
                        Text("View All")
                            .font(Theme.subheadline)
                            .foregroundStyle(Theme.accentA)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                
                let insights = analytics.generateInsights()
                
                if insights.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("Complete more workouts to see insights")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .fill(.ultraThinMaterial)
                            
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.2),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blendMode(.overlay)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                        )
                    )
                    .softShadow()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(insights.prefix(3)) { insight in
                                QuickInsightCard(insight: insight)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                    }
                }
            }
        }
    }
    
    // MARK: - Agent 10: Goals Section
    
    @ViewBuilder
    private func goalsSection(goalManager: GoalManager) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Goals")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    showGoals = true
                    Haptics.tap()
                } label: {
                    Text("Manage")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            if goalManager.weeklyGoal > 0 || goalManager.monthlyGoal > 0 {
                VStack(spacing: DesignSystem.Spacing.md) {
                    if goalManager.weeklyGoal > 0 {
                        GoalProgressCard(
                            title: "Weekly Goal",
                            current: goalManager.weeklyProgress,
                            goal: goalManager.weeklyGoal,
                            progress: goalManager.weeklyProgressPercentage,
                            isAchieved: goalManager.isWeeklyGoalAchieved,
                            color: Theme.accentA
                        )
                    }
                    
                    if goalManager.monthlyGoal > 0 {
                        GoalProgressCard(
                            title: "Monthly Goal",
                            current: goalManager.monthlyProgress,
                            goal: goalManager.monthlyGoal,
                            progress: goalManager.monthlyProgressPercentage,
                            isAchieved: goalManager.isMonthlyGoalAchieved,
                            color: Theme.accentB
                        )
                    }
                }
            } else {
                Button {
                    showGoals = true
                    Haptics.tap()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "target")
                            .font(.title3)
                            .foregroundStyle(Theme.accentA)
                            .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Set Your Goals")
                                .font(Theme.subheadline)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Track your progress with weekly and monthly goals")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                    .cardPadding()
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                    .stroke(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.5), lineWidth: DesignSystem.Border.standard)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func greeting() -> String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Hello"
        }
    }
    
    // MARK: - Agent 3: Engine Configuration
    
    private func configureEngineFromPreferences() {
        // Note: WorkoutEngine currently uses default durations
        // Configuration from preferences would require engine modifications
        // For now, engine uses standard 30s exercise / 10s rest / 10s prep durations
        let prefs = preferencesStore.preferences
        
        // TODO: Implement engine configuration if needed
        // The engine currently doesn't support runtime configuration
        // It would need to be recreated with new parameters or have configurable properties
    }
}

// MARK: - Stat Box (Master Designer Polish)

private struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Icon with premium styling
            ZStack {
                Circle()
                    .fill(color.opacity(DesignSystem.Opacity.highlight))
                    .frame(width: DesignSystem.IconSize.statBox + 8, height: DesignSystem.IconSize.statBox + 8)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            }
            .accessibilityHidden(true)
            
            Text(value)
                .font(Theme.title2)
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle color gradient overlay
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(DesignSystem.Opacity.highlight * 0.5),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                // Refined border with gradient
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(DesignSystem.Opacity.light * 1.2),
                                color.opacity(DesignSystem.Opacity.subtle),
                                color.opacity(DesignSystem.Opacity.light * 1.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
            .overlay(
                // Subtle glow
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(color.opacity(DesignSystem.Opacity.glow * 0.6), lineWidth: DesignSystem.Border.hairline)
                    .blur(radius: 1)
            )
        )
        .softShadow()
    }
}

// MARK: - Exercise Preview Card (Master Designer Polish)

private struct ExercisePreviewCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Icon with premium styling
            ZStack {
                Circle()
                    .fill(Theme.accentA.opacity(DesignSystem.Opacity.highlight * 1.5))
                    .frame(width: DesignSystem.IconSize.large + 8, height: DesignSystem.IconSize.large + 8)
                
                Image(systemName: exercise.icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: DesignSystem.IconSize.large, height: DesignSystem.IconSize.large)
            }
            
            Text(exercise.name)
                .font(Theme.caption)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 120, height: 100)
        .background(
            ZStack {
                // Base material
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                // Refined border
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                Theme.accentA.opacity(DesignSystem.Opacity.light * 0.5),
                                Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.subtle
                    )
            )
        )
        .softShadow()
    }
}

// MARK: - Workout History Row (removed - now in Views/History/WorkoutHistoryRow.swift)
// MARK: - Exercise List View (removed - now in Views/Exercises/ExerciseListView.swift)
// MARK: - Workout History View (removed - now in Views/History/WorkoutHistoryView.swift)

// MARK: - Agent 2: Quick Insight Card

private struct QuickInsightCard: View {
    let insight: WorkoutInsight
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: insight.icon)
                    .font(.title3)
                    .foregroundStyle(insight.color)
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
                
                Text(insight.title)
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
            }
            
            Text(insight.message)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(insight.color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
                )
        )
        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.subtle * 0.5), 
               radius: DesignSystem.Shadow.small.radius * 0.5, 
               y: DesignSystem.Shadow.small.y * 0.5)
    }
}

// MARK: - Agent 2: Analytics Main View

struct AnalyticsMainView: View {
    @EnvironmentObject private var store: WorkoutStore
    @EnvironmentObject private var analytics: WorkoutAnalytics
    @EnvironmentObject private var achievementManager: AchievementManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Charts
                ProgressChartView(analytics: analytics)
                
                // Calendar
                WeeklyCalendarView(analytics: analytics)
                
                // Exercise completion
                ExerciseCompletionChartView(analytics: analytics)
                
                // Frequency chart
                WorkoutFrequencyChartView(analytics: analytics)
            }
            .contentPadding()
        }
        .background(ThemeBackground())
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                    Haptics.tap()
                }
                .font(Theme.headline)
            }
        }
    }
}

// MARK: - Agent 10: Goal Progress Card

private struct GoalProgressCard: View {
    let title: String
    let current: Int
    let goal: Int
    let progress: Double
    let isAchieved: Bool
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text(title)
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                if isAchieved {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(Theme.caption)
                        Text("Achieved!")
                            .font(Theme.caption)
                            .foregroundStyle(.green)
                    }
                } else {
                    Text("\(current) / \(goal)")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.75, style: .continuous)
                        .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                    
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.75, style: .continuous)
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * progress)
                        .animation(AnimationConstants.smoothSpring, value: progress)
                }
            }
            .frame(height: DesignSystem.Spacing.sm)
            
            if !isAchieved {
                Text("\(Int(progress * 100))% complete")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

