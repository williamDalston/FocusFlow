import SwiftUI

/// Agent 10: Focus Content View - Exceptional home screen experience for Pomodoro Timer
/// Refactored from WorkoutContentView for Pomodoro Timer app
/// Creates world-class main focus content view with exceptional UX, animations, and intelligent features
struct FocusContentView: View {
    @EnvironmentObject private var store: FocusStore
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var preferencesStore: FocusPreferencesStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var engine = PomodoroEngine()
    @State private var showTimerView = false
    @State private var showHistory = false
    @State private var showCustomization = false
    @State private var showAnalytics = false
    @State private var showAchievements = false
    @State private var showInsights = false
    @State private var showGoals = false
    @State private var showPresets = false
    
    @StateObject private var messageManager = MotivationalMessageManager.shared
    @State private var showAchievementCelebration: AchievementNotifier.Achievement? = nil
    
    // Analytics - Use lazy initialization to get store from environment
    @State private var analytics: FocusAnalytics?
    @State private var achievementManager: AchievementManager?
    
    // Agent 10: Goals - Goal management system
    @State private var goalManager: GoalManager?
    
    // Insights time range filter
    @State private var selectedInsightsTimeRange: InsightsTimeRange = .all
    
    // Daily Motivation toggle
    @AppStorage("dailyMotivationEnabled") private var dailyMotivationEnabled = true
    
    @AppStorage("hasSeenHomepageFlourishes") private var hasSeenHomepageFlourishes = false
    
    // Current preset and cycle info
    private var currentPreset: PomodoroPreset {
        preferencesStore.preferences.selectedPreset
    }
    
    private var cycleProgress: Int {
        store.currentCycle?.sessionsCompleted ?? 1
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            // Subtle floating particles for first-time users (only show once)
            if !hasSeenHomepageFlourishes {
                FloatingParticles()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .opacity(DesignSystem.Opacity.medium)
            }
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Focus Card - single hero card with primary CTA per Apple HIG
                        HeroFocusCard(
                            focusStore: store,
                            preferencesStore: preferencesStore,
                            onStartFocus: {
                                configureEngineFromPreferences()
                                engine.stop()
                                showTimerView = true
                                Haptics.tap()
                            },
                            onCustomize: {
                                showCustomization = true
                                Haptics.tap()
                            },
                            onViewHistory: {
                                showHistory = true
                                Haptics.tap()
                            },
                            isFirstFocus: store.sessions.isEmpty
                        )
                        .padding(.bottom, DesignSystem.Spacing.md)
                        
                        // Three chips outside hero card in single row (3 equal buttons)
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Button(action: {
                                showCustomization = true
                                Haptics.tap()
                            }) {
                                Text("Customize")
                                    .font(Theme.subheadline.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.9)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: DesignSystem.TouchTarget.minimum)
                            }
                            .buttonStyle(SecondaryGlassButtonStyle())
                            .accessibilityLabel("Customize")
                            .accessibilityHint("Double tap to customize your focus timer")
                            .fadeSlideIn(delay: 0.4, direction: .up)
                            
                            Button(action: {
                                showPresets = true
                                Haptics.tap()
                            }) {
                                Text("Presets")
                                    .font(Theme.subheadline.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.9)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: DesignSystem.TouchTarget.minimum)
                            }
                            .buttonStyle(SecondaryGlassButtonStyle())
                            .accessibilityLabel("Presets")
                            .accessibilityHint("Double tap to see all Pomodoro presets")
                            .fadeSlideIn(delay: 0.5, direction: .up)
                            
                            Button(action: {
                                showHistory = true
                                Haptics.tap()
                            }) {
                                Text("History")
                                    .font(Theme.subheadline.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.9)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: DesignSystem.TouchTarget.minimum)
                            }
                            .buttonStyle(SecondaryGlassButtonStyle())
                            .accessibilityLabel("History")
                            .accessibilityHint("Double tap to view your focus session history")
                            .fadeSlideIn(delay: 0.6, direction: .up)
                        }
                        .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Spacing.sectionSpacingIPad : DesignSystem.Spacing.sectionSpacing)
                        
                        // Daily Motivation card (only if enabled)
                        if dailyMotivationEnabled {
                            // Enhanced visual separator
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                                .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                            
                            dailyQuoteCard
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                                .fadeSlideIn(delay: 0.7, direction: .up)
                        }
                        
                        // Enhanced visual separator between major sections
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5))
                            .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                        
                        statsGrid
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                            .fadeSlideIn(delay: 0.8, direction: .up)
                        
                        // Next Achievement (Prominent)
                        if let manager = achievementManager, let nextAchievement = manager.nextAchievement() {
                            // Enhanced visual separator
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                                .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                            
                            NextAchievementCard(
                                achievement: nextAchievement.achievement,
                                remaining: nextAchievement.remaining,
                                progressText: nextAchievement.progressText,
                                achievementManager: manager
                            ) {
                                showAchievements = true
                                Haptics.tap()
                            }
                            .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                        }
                        
                        // Achievement Progress Cards (showing closest achievements)
                        if let manager = achievementManager, !manager.closestAchievements(limit: 3).isEmpty {
                            // Enhanced visual separator
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                                .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                            
                            achievementProgressSection(manager: manager)
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                        }
                        
                        // Recent Achievements
                        if let manager = achievementManager, !manager.recentUnlocks.isEmpty {
                            // Enhanced visual separator
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                                .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                            
                            RecentAchievementsView(achievementManager: manager)
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                        }
                        
                        // Quick Insights
                        if analytics != nil {
                            // Enhanced visual separator
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                                .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                            
                            quickInsightsSection
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                        }
                        
                        // Goals Section
                        if let goalManager = goalManager {
                            // Enhanced visual separator
                            Divider()
                                .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                                .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                            
                            goalsSection(goalManager: goalManager)
                                .padding(.bottom, horizontalSizeClass == .regular ? DesignSystem.Hierarchy.majorSectionSpacing : DesignSystem.Hierarchy.minorSectionSpacing)
                        }
                        
                        // Enhanced visual separator
                        Divider()
                            .background(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.2))
                            .padding(.vertical, DesignSystem.Hierarchy.subsectionSpacing)
                        
                        recentFocusSessions
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
                FocusTimerView(engine: engine)
                    .environmentObject(store)
            }
            .interactiveDismissDisabled(engine.phase != .idle && engine.phase != .completed)
            .iPadOptimizedSheetPresentation()
            .onAppear {
                // Ensure engine is ready and configured
                if engine.phase == .completed {
                    engine.reset()
                }
                // Configure engine from preferences before timer view appears
                configureEngineFromPreferences()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut))) { _ in
            // Handle shortcut-triggered focus start
            engine.stop()
            showTimerView = true
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                FocusHistoryView()
                    .environmentObject(store)
            }
            .iPadOptimizedSheetPresentation()
        }
        .sheet(isPresented: $showCustomization) {
            FocusCustomizationView()
                .environmentObject(preferencesStore)
            .iPadOptimizedSheetPresentation()
        }
        .sheet(item: $showAchievementCelebration) { achievement in
            AchievementCelebrationView(achievement: achievement)
                .iPadOptimizedSheetPresentation()
        }
        .sheet(isPresented: $showAnalytics) {
            if let analytics = analytics {
                NavigationStack {
                    FocusAnalyticsMainView(analytics: analytics)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showAnalytics = false
                                    Haptics.tap()
                                }
                            }
                        }
                }
                .iPadOptimizedSheetPresentation()
            }
        }
        .sheet(isPresented: $showAchievements) {
            if let manager = achievementManager {
                NavigationStack {
                    AchievementsView(achievementManager: manager)
                }
                .iPadOptimizedSheetPresentation()
            }
        }
        .sheet(isPresented: $showInsights) {
            if let analytics = analytics {
                NavigationStack {
                    FocusInsightsView(analytics: analytics)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showInsights = false
                                    Haptics.tap()
                                }
                            }
                        }
                }
                .iPadOptimizedSheetPresentation()
            }
        }
        .sheet(isPresented: $showGoals) {
            if let goalManager = goalManager {
                NavigationStack {
                    GoalSettingView(goalManager: goalManager)
                }
                .iPadOptimizedSheetPresentation()
            }
        }
        .sheet(isPresented: $showPresets) {
            NavigationStack {
                PomodoroPresetSelectorView(
                    selectedPreset: Binding(
                        get: { preferencesStore.preferences.selectedPreset },
                        set: { preferencesStore.updateSelectedPreset($0) }
                    )
                )
                .environmentObject(preferencesStore)
            }
            .iPadOptimizedSheetPresentation()
        }
        .undoToast() // Enable undo toast notifications
        // Enhanced theme transitions with elegant crossfade
        .animation(AnimationConstants.longEase, value: theme.colorTheme)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .crossfadeTransition(duration: 0.52)  // Smooth color transitions
        .onAppear {
            // Mark that user has seen homepage flourishes after animation completes
            if !hasSeenHomepageFlourishes {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    hasSeenHomepageFlourishes = true
                }
            }
            
            // Progressive loading - show cached stats immediately, load analytics in background
            // Initialize analytics with current store (async to avoid blocking UI)
            Task { @MainActor in
                if analytics == nil {
                    analytics = FocusAnalytics(store: store)
                }
                if achievementManager == nil {
                    achievementManager = AchievementManager(store: store)
                }
                // Initialize goal manager
                if goalManager == nil {
                    goalManager = GoalManager(store: store)
                }
                
                // Check achievements
                achievementManager?.checkAchievements()
                
                // Update goal progress
                goalManager?.updateProgress()
            }
            
            // Load personalized message (synchronous - fast)
            messageManager.personalizedMessage = messageManager.getPersonalizedMessage(
                streak: store.streak,
                totalWorkouts: store.totalSessions,
                workoutsThisWeek: store.sessionsThisWeek
            )
            
            // Configure engine from preferences
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.selectedPreset) { _ in
            // Update engine configuration when preset changes
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.customFocusDuration) { _ in
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.customShortBreakDuration) { _ in
            configureEngineFromPreferences()
        }
        .onChange(of: preferencesStore.preferences.customLongBreakDuration) { _ in
            configureEngineFromPreferences()
        }
    }
    
    // MARK: - Daily Quote Card
    
    private var dailyQuoteCard: some View {
        DailyQuoteView()
    }
    
    // MARK: - Stats Grid
    
    /// Check if data is still loading
    private var isDataLoading: Bool {
        analytics == nil || achievementManager == nil || goalManager == nil
    }
    
    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                // Increased section title size and weight for hierarchy
                Text("Your Progress")
                    .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                // Achievement preview in stats header
                if let manager = achievementManager, let next = manager.nextAchievement() {
                    Button {
                        showAchievements = true
                        Haptics.tap()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: next.achievement.icon)
                                .font(Theme.caption2)
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
            
            // Show skeleton loaders while data is loading
            if isDataLoading {
                SkeletonStatsGrid()
                    .loadingTransition(isDataLoading)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.gridSpacing) {
                    FocusStatBox(
                        title: "Total Sessions",
                        value: store.totalSessions,
                        icon: "timer",
                        color: Theme.accentA,
                        nextMilestone: nextMilestone(for: store.totalSessions),
                        achievementManager: achievementManager
                    )
                    
                    FocusStatBox(
                        title: "This Week",
                        value: store.sessionsThisWeek,
                        icon: "calendar",
                        color: Theme.accentB,
                        nextMilestone: 7,  // Weekly goal
                        achievementManager: achievementManager
                    )
                    
                    FocusStatBox(
                        title: "This Month",
                        value: store.sessionsThisMonth,
                        icon: "chart.bar.fill",
                        color: Theme.accentC,
                        nextMilestone: nextMilestone(for: store.sessionsThisMonth),
                        achievementManager: achievementManager
                    )
                    
                    FocusStatBox(
                        title: "Focus Time",
                        value: Int(store.totalFocusTime),
                        icon: "clock.fill",
                        color: Theme.accentA,
                        nextMilestone: nextMinutesMilestone(for: Int(store.totalFocusTime)),
                        achievementManager: achievementManager,
                        unit: "min"
                    )
                }
                .loadingTransition(isDataLoading)
            }
        }
    }
    
    // MARK: - Achievement Progress Section
    
    @ViewBuilder
    private func achievementProgressSection(manager: AchievementManager) -> some View {
        let closest = manager.closestAchievements(limit: 3)
        
        if !closest.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    // Increased section title size and weight
                    Text("Next Achievements")
                        .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    Button {
                        showAchievements = true
                        Haptics.tap()
                    } label: {
                        // Reduced visual weight of secondary action
                        Text("View All")
                            .font(Theme.subheadline)
                            .foregroundStyle(Theme.accentA.opacity(DesignSystem.Hierarchy.secondaryOpacity))
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
    
    // MARK: - Recent Focus Sessions
    
    private var recentFocusSessions: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                // Increased section title size and weight
                Text("Recent Sessions")
                    .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button {
                    showHistory = true
                    Haptics.tap()
                } label: {
                    // Reduced visual weight of secondary action
                    Text("View All")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA.opacity(DesignSystem.Hierarchy.secondaryOpacity))
                }
                .accessibilityLabel("View All Focus History")
                .accessibilityHint("Double tap to see all your past focus sessions.")
                .accessibilityAddTraits(.isButton)
                .accessibilityTouchTarget()
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            
            // Show skeleton loader while data is loading
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
                        
                        Image(systemName: "timer")
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
                        
                        Text("Complete your first focus session to see your progress and build your streak!")
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
                            Label("Start First Session", systemImage: "timer")
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
                    ForEach(store.sessions.filter { $0.phaseType == .focus }.prefix(5)) { session in
                        FocusHistoryRow(session: session)
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Insights Section
    
    @ViewBuilder
    private var quickInsightsSection: some View {
        if let analytics = analytics {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    // Increased section title size and weight
                    Text("Insights")
                        .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .allowsTightening(false) // Prevent hyphen splits
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    Button {
                        showInsights = true
                        Haptics.tap()
                    } label: {
                        // Reduced visual weight of secondary action
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text("View All")
                                .font(Theme.subheadline)
                                .foregroundStyle(Theme.accentA.opacity(DesignSystem.Hierarchy.secondaryOpacity))
                            Image(systemName: "chevron.right")
                                .font(Theme.caption)
                                .foregroundStyle(Theme.accentA.opacity(DesignSystem.Hierarchy.secondaryOpacity))
                        }
                    }
                    .accessibilityLabel("View All Insights")
                    .accessibilityHint("Double tap to see detailed analytics and focus insights.")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityTouchTarget()
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                
                // Segmented control ("All / 7d / 30d") above Insights
                Picker("Time Range", selection: $selectedInsightsTimeRange) {
                    Text("All").tag(InsightsTimeRange.all)
                    Text("7d").tag(InsightsTimeRange.week)
                    Text("30d").tag(InsightsTimeRange.month)
                }
                .pickerStyle(.segmented)
                .tint(Theme.accentA)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                
                let insights = generateFocusInsights(analytics: analytics, timeRange: selectedInsightsTimeRange)
                
                if insights.isEmpty {
                    InlineEmptyState(
                        icon: "chart.bar.xaxis",
                        message: "Complete more focus sessions to see insights"
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
                                QuickFocusInsightCard(insight: insight)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                    }
                }
            }
        }
    }
    
    // MARK: - Goals Section
    
    @ViewBuilder
    private func goalsSection(goalManager: GoalManager) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                // Increased section title size and weight
                Text("Goals")
                    .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button {
                    showGoals = true
                    Haptics.tap()
                } label: {
                    // Reduced visual weight of secondary action
                    Text("Manage")
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA.opacity(DesignSystem.Hierarchy.secondaryOpacity))
                }
                .accessibilityLabel("Manage Goals")
                .accessibilityHint("Double tap to set or modify your weekly and monthly focus goals.")
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
                            color: Theme.accentA,
                            onEdit: {
                                showGoals = true
                                Haptics.tap()
                            }
                        )
                    }
                    
                    if goalManager.monthlyGoal > 0 {
                        GoalProgressCard(
                            title: "Monthly Goal",
                            current: goalManager.monthlyProgress,
                            goal: goalManager.monthlyGoal,
                            progress: goalManager.monthlyProgressPercentage,
                            isAchieved: goalManager.isMonthlyGoalAchieved,
                            color: Theme.accentB,
                            onEdit: {
                                showGoals = true
                                Haptics.tap()
                            }
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
                            Text("Weekly & monthly goals")
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
    
    /// Configures the Pomodoro engine with user preferences
    private func configureEngineFromPreferences() {
        let prefs = preferencesStore.preferences
        
        // Apply preferences to engine (only if timer is not in progress)
        guard engine.phase == .idle || engine.phase == .completed else {
            // If timer is in progress, preferences will apply on next session
            return
        }
        
        // Update engine durations from preferences
        if prefs.useCustomIntervals {
            engine.focusDuration = prefs.customFocusDuration
            engine.shortBreakDuration = prefs.customShortBreakDuration
            engine.longBreakDuration = prefs.customLongBreakDuration
            engine.cycleLength = prefs.customCycleLength
        } else {
            let preset = prefs.selectedPreset
            engine.focusDuration = preset.focusDuration
            engine.shortBreakDuration = preset.shortBreakDuration
            engine.longBreakDuration = preset.longBreakDuration
            engine.cycleLength = preset.cycleLength
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
    
    // MARK: - Insights Generation
    
    private func generateFocusInsights(analytics: FocusAnalytics, timeRange: InsightsTimeRange) -> [FocusInsight] {
        var insights: [FocusInsight] = []
        
        // Get sessions based on time range
        let calendar = Calendar.current
        let today = Date()
        let sessions: [FocusSession]
        
        switch timeRange {
        case .all:
            sessions = store.sessions.filter { $0.phaseType == .focus }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
            sessions = store.sessions.filter { $0.phaseType == .focus && $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
            sessions = store.sessions.filter { $0.phaseType == .focus && $0.date >= monthAgo }
        }
        
        guard !sessions.isEmpty else { return [] }
        
        // Generate insights based on data
        let totalSessions = sessions.count
        let totalMinutes = sessions.reduce(0) { $0 + Int($1.duration / 60) }
        let averageDuration = totalMinutes / totalSessions
        
        // Best focus time insight
        if let bestTime = analytics.bestFocusTime {
            insights.append(FocusInsight(
                id: UUID(),
                title: "Best Focus Time",
                message: "You're most productive at \(bestTime)",
                icon: "clock.fill",
                color: Theme.accentA
            ))
        }
        
        // Streak insight
        if store.streak > 0 {
            insights.append(FocusInsight(
                id: UUID(),
                title: "Current Streak",
                message: "\(store.streak) day streak! Keep it up!",
                icon: "flame.fill",
                color: Theme.accentB
            ))
        }
        
        // Average duration insight
        if averageDuration > 0 {
            insights.append(FocusInsight(
                id: UUID(),
                title: "Average Session",
                message: "\(averageDuration) minutes per session",
                icon: "timer",
                color: Theme.accentC
            ))
        }
        
        return insights
    }
}

// MARK: - Focus Stat Box

private struct FocusStatBox: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let nextMilestone: Int?
    let achievementManager: AchievementManager?
    var unit: String = ""
    
    var progress: Double {
        guard let milestone = nextMilestone, milestone > 0 else { return 0 }
        return min(Double(value) / Double(milestone), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Icon with premium styling
            ZStack {
                Circle()
                    .fill(color.opacity(DesignSystem.Opacity.highlight))
                    .frame(width: DesignSystem.IconSize.statBox + 8, height: DesignSystem.IconSize.statBox + 8)
                
                Image(systemName: icon)
                    .font(Theme.title3)
                    .foregroundStyle(color)
                    .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            }
            .accessibilityHidden(true)
            
            // Enhanced hero metrics with larger, bolder typography
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                AnimatedGradientCounter(
                    value: value,
                    duration: 0.8,
                    font: title == "Total Sessions"
                        ? .system(size: 56, weight: DesignSystem.Hierarchy.primaryWeight, design: .rounded)
                        : .system(size: 44, weight: DesignSystem.Hierarchy.primaryWeight, design: .rounded),
                    gradient: LinearGradient(
                        colors: [
                            Theme.textPrimary,
                            Theme.textPrimary.opacity(0.95),
                            Theme.textPrimary.opacity(0.9),
                            Theme.textPrimary.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility5)
            .monospacedDigit()
            .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.6),
                   radius: DesignSystem.Shadow.soft.radius,
                   x: 0, y: DesignSystem.Shadow.soft.y * 0.5)
            .accessibilityLabel("\(title): \(value)\(unit.isEmpty ? "" : " \(unit)")")
            .accessibilityAddTraits(.updatesFrequently)
            
            // Reduced visual weight of secondary information
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.tertiaryOpacity))
                .lineLimit(2)
                .accessibilityHidden(true)
            
            // Progress indicator
            if let milestone = nextMilestone {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    // Progress language with monospaced digits
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text("\(value) / \(milestone)")
                            .font(Theme.caption2)
                            .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.quaternaryOpacity))
                            .monospacedDigit()
                        
                        Text("·")
                            .font(Theme.caption2)
                            .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.quaternaryOpacity))
                        
                        Text("Goal: \(milestone)")
                            .font(Theme.caption2)
                            .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.quaternaryOpacity))
                            .monospacedDigit()
                    }
                    
                    // Enhanced progress bar with animated gradient
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5, style: .continuous)
                                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                            
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            color,
                                            color.opacity(0.9),
                                            color.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress)
                                .shadow(color: color.opacity(DesignSystem.Opacity.glow * 0.6), radius: 2, x: 0, y: 1)
                                .animation(AnimationConstants.elegantSpring, value: progress)
                        }
                    }
                    .frame(height: 3)
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

// MARK: - Quick Focus Insight Card

private struct QuickFocusInsightCard: View {
    let insight: FocusInsight
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: insight.icon)
                    .font(Theme.title3)
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

// MARK: - Insights Time Range

private enum InsightsTimeRange: String, CaseIterable {
    case all = "all"
    case week = "week"
    case month = "month"
}
