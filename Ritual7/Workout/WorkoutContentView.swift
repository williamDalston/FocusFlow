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
                    VStack(spacing: 0) {
                        header
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        
                        quickStartCard  // Moved to top 3 for better prominence
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        dailyQuoteCard
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        statsGrid
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        
                        // Agent 21: Next Achievement (Prominent)
                        if let manager = achievementManager, let nextAchievement = manager.nextAchievement() {
                            // Subtle divider
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                                .padding(.vertical, DesignSystem.Spacing.lg)
                            
                            NextAchievementCard(
                                achievement: nextAchievement.achievement,
                                remaining: nextAchievement.remaining,
                                progressText: nextAchievement.progressText,
                                achievementManager: manager
                            ) {
                                showAchievements = true
                                Haptics.tap()
                            }
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        }
                        
                        // Agent 21: Achievement Progress Cards (showing closest achievements)
                        if let manager = achievementManager, !manager.closestAchievements(limit: 3).isEmpty {
                            // Subtle divider
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                                .padding(.vertical, DesignSystem.Spacing.lg)
                            
                            achievementProgressSection(manager: manager)
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        }
                        
                        // Agent 2: Recent Achievements
                        if let manager = achievementManager, !manager.recentUnlocks.isEmpty {
                            // Subtle divider
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                                .padding(.vertical, DesignSystem.Spacing.lg)
                            
                            RecentAchievementsView(achievementManager: manager)
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        }
                        
                        // Agent 2: Quick Insights
                        if analytics != nil {
                            // Subtle divider
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                                .padding(.vertical, DesignSystem.Spacing.lg)
                            
                            quickInsightsSection
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        }
                        
                        // Agent 10: Goals Section
                        if let goalManager = goalManager {
                            // Subtle divider
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                                .padding(.vertical, DesignSystem.Spacing.lg)
                            
                            goalsSection(goalManager: goalManager)
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        }
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
                        exerciseListPreview
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        
                        // Subtle divider
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle))
                            .padding(.vertical, DesignSystem.Spacing.lg)
                        
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
        // Agent 4: Use AnimationConstants for theme transitions
        .animation(AnimationConstants.longEase, value: theme.colorTheme)
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
            
            // Configure engine from preferences
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.exerciseDuration) { _ in
            // Update engine configuration when preferences change
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.restDuration) { _ in
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.prepDuration) { _ in
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.skipPrepTime) { _ in
            configureEngineFromPreferences()
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
    
    @State private var breathingAnimation: Bool = false
    
    private var quickStartCard: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Exercise preview icons in a row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(Array(Exercise.sevenMinuteWorkout.prefix(8)), id: \.id) { exercise in
                                Image(systemName: exercise.icon)
                                    .font(.system(size: DesignSystem.IconSize.medium, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Theme.accentA, Theme.accentB],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: DesignSystem.IconSize.xlarge, height: DesignSystem.IconSize.xlarge)
                                    .background(
                                        Circle()
                                            .fill(Theme.accentA.opacity(DesignSystem.Opacity.highlight))
                                    )
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                    }
                    .frame(height: 40)
                    
                    // Main icon with breathing animation
                    Image(systemName: "figure.run")
                        .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accentA, Theme.accentB],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(breathingAnimation ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: breathingAnimation
                        )
                        .onAppear {
                            breathingAnimation = true
                        }
                    
                    Text("Ready to Work Out?")
                        .font(Theme.title.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("12 exercises • 7 minutes • No equipment needed")
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Estimated calories and time
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        Label("~84 calories", systemImage: "flame.fill")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.accentB)
                        Label("~7 min", systemImage: "clock.fill")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.accentC)
                    }
                    .padding(.top, DesignSystem.Spacing.xs)
                }
                
                Button {
                    // Configure engine from preferences before starting
                    configureEngineFromPreferences()
                    // Reset engine before starting
                    engine.stop()
                    showTimerView = true
                    Haptics.tap()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "play.fill")
                            .font(.system(size: DesignSystem.IconSize.medium, weight: .bold))
                        Text("Start Workout")
                            .fontWeight(.bold)
                            .font(.system(size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.ButtonSize.large.height + 8) // Larger button
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .keyboardShortcut(.return, modifiers: [])  // Enter key to start workout for simulator testing
                .disabled(engine.phase != .idle && engine.phase != .completed)
                .accessibilityLabel("Start Workout")
                .accessibilityHint("Double tap to begin your 7-minute workout. Press Enter key to start workout.")
                .accessibilityAddTraits(.isButton)
                
                HStack(spacing: 16) {
                    Button {
                        showCustomization = true
                        Haptics.tap()
                    } label: {
                        Label("Customize", systemImage: "slider.horizontal.3")
                            .font(Theme.subheadline.weight(.medium))
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    .accessibilityLabel("Customize Workout")
                    .accessibilityHint("Double tap to customize exercise duration, rest periods, and workout preferences.")
                    .accessibilityAddTraits(.isButton)
                    
                    Button {
                        showExerciseList = true
                        Haptics.tap()
                    } label: {
                        Label("View Exercises", systemImage: "list.bullet")
                            .font(Theme.subheadline.weight(.medium))
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    .accessibilityLabel("View Exercises")
                    .accessibilityHint("Double tap to see all available exercises with descriptions and instructions.")
                    .accessibilityAddTraits(.isButton)
                    
                    Button {
                        showHistory = true
                        Haptics.tap()
                    } label: {
                        Label("History", systemImage: "clock")
                            .font(Theme.subheadline.weight(.medium))
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                    .accessibilityLabel("Workout History")
                    .accessibilityHint("Double tap to view your past workout sessions and progress.")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
    }
    
    // MARK: - Stats Grid
    
    /// Agent 16: Check if data is still loading
    private var isDataLoading: Bool {
        analytics == nil || achievementManager == nil || goalManager == nil
    }
    
    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Your Progress")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                // Agent 21: Achievement preview in stats header
                if let manager = achievementManager, let next = manager.nextAchievement() {
                    Button {
                        showAchievements = true
                        Haptics.tap()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: next.achievement.icon)
                                .font(.caption2)
                                .foregroundStyle(next.achievement.color)
                            Text("\(next.remaining)")
                                .font(Theme.caption2)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(next.achievement.color.opacity(DesignSystem.Opacity.highlight * 0.3))
                        )
                    }
                    .accessibilityLabel("\(next.progressText). Tap to view all achievements.")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            // Agent 16: Show skeleton loaders while data is loading
            if isDataLoading {
                SkeletonStatsGrid()
                    .loadingTransition(isDataLoading)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.gridSpacing) {
                    StatBox(
                        title: "Total Workouts",
                        value: store.totalWorkouts,
                        icon: "figure.run",
                        color: Theme.accentA,
                        nextMilestone: nextMilestone(for: store.totalWorkouts),
                        achievementManager: achievementManager
                    )
                    
                    StatBox(
                        title: "This Week",
                        value: store.workoutsThisWeek,
                        icon: "calendar",
                        color: Theme.accentB,
                        nextMilestone: 7,  // Weekly goal
                        achievementManager: achievementManager
                    )
                    
                    StatBox(
                        title: "This Month",
                        value: store.workoutsThisMonth,
                        icon: "chart.bar.fill",
                        color: Theme.accentC,
                        nextMilestone: nextMilestone(for: store.workoutsThisMonth),
                        achievementManager: achievementManager
                    )
                    
                    StatBox(
                        title: "Total Minutes",
                        value: Int(store.totalMinutes),
                        icon: "clock.fill",
                        color: Theme.accentA,
                        nextMilestone: nextMinutesMilestone(for: Int(store.totalMinutes)),
                        achievementManager: achievementManager
                    )
                }
                .loadingTransition(isDataLoading)
            }
        }
    }
    
    // MARK: - Agent 21: Achievement Progress Section
    
    @ViewBuilder
    private func achievementProgressSection(manager: AchievementManager) -> some View {
        let closest = manager.closestAchievements(limit: 3)
        
        if !closest.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Text("Next Achievements")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    Button {
                        showAchievements = true
                        Haptics.tap()
                    } label: {
                        Text("View All")
                            .font(Theme.subheadline)
                            .foregroundStyle(Theme.accentA)
                    }
                    .accessibilityLabel("View All Achievements")
                    .accessibilityHint("Double tap to see all available achievements.")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityTouchTarget()
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(closest, id: \.achievement.id) { item in
                            AchievementProgressCard(
                                achievement: item.achievement,
                                remaining: item.remaining,
                                progress: item.progress,
                                progressText: item.progressText,
                                achievementManager: manager
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                }
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
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button {
                    showExerciseList = true
                    Haptics.tap()
                } label: {
                    Text("View All")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                }
                .accessibilityLabel("View All Exercises")
                .accessibilityHint("Double tap to see the complete list of exercises.")
                .accessibilityAddTraits(.isButton)
                .accessibilityTouchTarget()
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(Array(Exercise.sevenMinuteWorkout.prefix(6).enumerated()), id: \.element.id) { index, exercise in
                        ExercisePreviewCard(exercise: exercise)
                            .staggeredEntrance(index: index, delay: 0.08)
                            .cardLift()
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
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button {
                    showHistory = true
                    Haptics.tap()
                } label: {
                    Text("View All")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                }
                .accessibilityLabel("View All Workout History")
                .accessibilityHint("Double tap to see all your past workout sessions.")
                .accessibilityAddTraits(.isButton)
                .accessibilityTouchTarget()
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            // Agent 16: Show skeleton loader while data is loading
            if isDataLoading {
                SkeletonList(count: 3)
                    .loadingTransition(isDataLoading)
            } else if store.sessions.isEmpty {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Enhanced icon with animation
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.highlight),
                                        Theme.accentB.opacity(DesignSystem.Opacity.highlight * 0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.subtle), 
                                   radius: DesignSystem.Shadow.medium.radius, 
                                   y: DesignSystem.Shadow.medium.y)
                        
                        Image(systemName: "figure.run")
                            .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accentA, Theme.accentB],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Start Your Journey")
                            .font(Theme.title3.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("Complete your first workout to see your progress and build your streak!")
                            .font(Theme.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                        
                        // Call to action button
                        Button {
                            configureEngineFromPreferences()
                            engine.stop()
                            showTimerView = true
                            Haptics.tap()
                        } label: {
                            Label("Start First Workout", systemImage: "play.fill")
                                .font(Theme.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                        .padding(.top, DesignSystem.Spacing.md)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.xl)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.highlight * 0.3),
                                        Theme.accentB.opacity(DesignSystem.Opacity.highlight * 0.2),
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
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    Button {
                        showInsights = true
                        Haptics.tap()
                    } label: {
                        Text("View All")
                            .font(Theme.subheadline)
                            .foregroundStyle(Theme.accentA)
                    }
                    .accessibilityLabel("View All Insights")
                    .accessibilityHint("Double tap to see detailed analytics and workout insights.")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityTouchTarget()
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                
                let insights = analytics.generateInsights()
                
                if insights.isEmpty {
                    InlineEmptyState(
                        icon: "chart.bar.xaxis",
                        message: "Complete more workouts to see insights"
                    )
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
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button {
                    showGoals = true
                    Haptics.tap()
                } label: {
                    Text("Manage")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                }
                .accessibilityLabel("Manage Goals")
                .accessibilityHint("Double tap to set or modify your weekly and monthly workout goals.")
                .accessibilityAddTraits(.isButton)
                .accessibilityTouchTarget()
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
                            .font(Theme.title3)
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
    
    /// Configures the workout engine with user preferences
    /// Applies exercise duration, rest duration, and prep duration from preferences
    private func configureEngineFromPreferences() {
        let prefs = preferencesStore.preferences
        
        // Apply preferences to engine (only if workout is not in progress)
        // This ensures users can change preferences without affecting an active workout
        guard engine.phase == .idle || engine.phase == .completed else {
            // If workout is in progress, preferences will apply on next workout
            return
        }
        
        // Update engine durations from preferences
        engine.exerciseDuration = prefs.exerciseDuration
        engine.restDuration = prefs.restDuration
        engine.prepDuration = prefs.skipPrepTime ? 0 : prefs.prepDuration
        
        // If a custom workout is selected, apply its exercises
        if let customWorkoutId = prefs.selectedCustomWorkoutId,
           let customWorkout = preferencesStore.getCustomWorkout(id: customWorkoutId) {
            // Note: WorkoutEngine exercises are set during initialization
            // For custom workouts, we would need to recreate the engine
            // This is a design limitation - custom workouts require restarting the workout
            // For now, custom workout selection is handled in WorkoutCustomizationView
        }
    }
    
    // MARK: - Progress Indicators Helpers
    
    private func nextMilestone(for value: Int) -> Int? {
        let milestones = [10, 25, 50, 100, 250, 500, 1000]
        return milestones.first { $0 > value }
    }
    
    private func nextMinutesMilestone(for value: Int) -> Int? {
        let milestones = [100, 250, 500, 1000, 2500, 5000, 10000]
        return milestones.first { $0 > value }
    }
}

// MARK: - Stat Box (Master Designer Polish)

private struct StatBox: View {
    let title: String
    let value: Int  // Changed to Int for animated counter
    let icon: String
    let color: Color
    let nextMilestone: Int?  // Next milestone to show progress toward
    let achievementManager: AchievementManager?  // Agent 21: For achievement previews
    
    var progress: Double {
        guard let milestone = nextMilestone, milestone > 0 else { return 0 }
        return min(Double(value) / Double(milestone), 1.0)
    }
    
    // Agent 21: Helper to find achievement related to stat
    private func findRelatedAchievement(for statTitle: String, manager: AchievementManager) -> (achievement: Achievement, progressText: String)? {
        let closest = manager.closestAchievements(limit: 5)
        
        // Match stat title to achievement type
        for item in closest {
            switch statTitle {
            case "Total Workouts":
                if [.firstWorkout, .fiftyWorkouts, .hundredWorkouts, .twoHundredWorkouts, .fiveHundredWorkouts, .thousandWorkouts].contains(item.achievement) {
                    return (item.achievement, item.progressText)
                }
            case "This Week":
                if item.achievement == .perfectWeek {
                    return (item.achievement, item.progressText)
                }
            case "This Month":
                if item.achievement == .monthlyConsistency {
                    return (item.achievement, item.progressText)
                }
            default:
                break
            }
        }
        return nil
    }
    
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
            
            // Animated counter instead of static text - Enhanced typography for hero metrics
            AnimatedGradientCounter(
                value: value,
                duration: 0.8,
                font: title == "Total Workouts" 
                    ? .system(size: 48, weight: .bold, design: .rounded)  // 48pt for total workouts
                    : .system(size: 36, weight: .bold, design: .rounded), // 36pt for other hero metrics
                gradient: LinearGradient(
                    colors: [Theme.textPrimary, Theme.textPrimary.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.5), 
                   radius: DesignSystem.Shadow.verySoft.radius * 0.5, 
                   x: 0, y: DesignSystem.Shadow.verySoft.y * 0.25)
            .accessibilityLabel("\(title): \(value)")
            .accessibilityAddTraits(.updatesFrequently)
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .accessibilityHidden(true) // Value already announced above
            
            // Mini progress bar showing progress toward next milestone
            if let milestone = nextMilestone, milestone > value {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5, style: .continuous)
                                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                            
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5, style: .continuous)
                                .fill(color.gradient)
                                .frame(width: geometry.size.width * progress)
                                .animation(AnimationConstants.smoothSpring, value: progress)
                        }
                    }
                    .frame(height: 3)
                    
                    // Agent 21: Show achievement preview if available
                    if let manager = achievementManager,
                       let relatedAchievement = findRelatedAchievement(for: title, manager: manager) {
                        Text(relatedAchievement.progressText)
                            .font(Theme.caption2)
                            .foregroundStyle(relatedAchievement.achievement.color)
                            .lineLimit(1)
                    } else {
                        Text("\(milestone - value) until \(milestone)")
                            .font(Theme.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .regularCardPadding()
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
                    .font(Theme.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
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
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(DesignSystem.Opacity.light * 1.5),
                                color.opacity(DesignSystem.Opacity.subtle),
                                color.opacity(DesignSystem.Opacity.light * 1.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(color.opacity(DesignSystem.Opacity.glow * 0.8), lineWidth: DesignSystem.Border.hairline)
                    .blur(radius: 1)
            )
        )
        .softShadow()
    }
}

// MARK: - Agent 21: Next Achievement Card

struct NextAchievementCard: View {
    let achievement: Achievement
    let remaining: Int
    let progressText: String
    let achievementManager: AchievementManager
    let onTap: () -> Void
    
    @EnvironmentObject private var theme: ThemeStore
    
    var progress: Double {
        achievementManager.progressForAchievement(achievement)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    // Icon with progress ring
                    ZStack {
                        // Progress ring
                        Circle()
                            .stroke(Color.gray.opacity(DesignSystem.Opacity.subtle), lineWidth: 6)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [achievement.color, achievement.color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(AnimationConstants.smoothSpring, value: progress)
                        
                        // Icon
                        Image(systemName: achievement.icon)
                            .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                            .foregroundStyle(achievement.color)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Next Achievement")
                            .font(Theme.footnote.smallCaps())
                            .foregroundStyle(.secondary)
                            .tracking(DesignSystem.Typography.uppercaseTracking)
                        
                        Text(achievement.title)
                            .font(Theme.title2.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text(progressText)
                            .font(Theme.subheadline)
                            .foregroundStyle(achievement.color)
                            .lineLimit(2)
                        
                        // Progress indicator
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5, style: .continuous)
                                        .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                                    
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5, style: .continuous)
                                        .fill(achievement.color.gradient)
                                        .frame(width: geometry.size.width * progress)
                                        .animation(AnimationConstants.smoothSpring, value: progress)
                                }
                            }
                            .frame(height: 4)
                            
                            Text("\(Int(progress * 100))%")
                                .font(Theme.caption2)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Gradient overlay
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    achievement.color.opacity(DesignSystem.Opacity.highlight * 0.4),
                                    achievement.color.opacity(DesignSystem.Opacity.highlight * 0.2),
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
                                    achievement.color.opacity(DesignSystem.Opacity.light * 1.5),
                                    achievement.color.opacity(DesignSystem.Opacity.subtle),
                                    achievement.color.opacity(DesignSystem.Opacity.light * 1.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.standard
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(achievement.color.opacity(DesignSystem.Opacity.glow * 0.8), lineWidth: DesignSystem.Border.hairline)
                        .blur(radius: 1)
                )
            )
            .softShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Next achievement: \(achievement.title). \(progressText)")
        .accessibilityHint("Double tap to view all achievements.")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Agent 21: Achievement Progress Card

struct AchievementProgressCard: View {
    let achievement: Achievement
    let remaining: Int
    let progress: Double
    let progressText: String
    let achievementManager: AchievementManager
    
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Icon with progress ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.gray.opacity(DesignSystem.Opacity.subtle), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [achievement.color, achievement.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(AnimationConstants.smoothSpring, value: progress)
                
                // Icon
                Image(systemName: achievement.icon)
                    .font(.system(size: DesignSystem.IconSize.large, weight: .semibold))
                    .foregroundStyle(achievement.color)
            }
            
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(achievement.title)
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(progressText)
                    .font(Theme.caption)
                    .foregroundStyle(achievement.color)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // Progress percentage
                Text("\(Int(progress * 100))%")
                    .font(Theme.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 140)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                achievement.color.opacity(DesignSystem.Opacity.highlight * 0.3),
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
                    .stroke(
                        LinearGradient(
                            colors: [
                                achievement.color.opacity(DesignSystem.Opacity.light * 1.2),
                                achievement.color.opacity(DesignSystem.Opacity.subtle)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: DesignSystem.Border.standard
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(achievement.color.opacity(DesignSystem.Opacity.glow * 0.6), lineWidth: DesignSystem.Border.hairline)
                    .blur(radius: 1)
            )
        )
        .softShadow()
        .accessibilityLabel("Achievement: \(achievement.title). \(progressText). \(Int(progress * 100)) percent complete.")
    }
}

