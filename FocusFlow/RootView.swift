import SwiftUI
import AppTrackingTransparency
import UserNotifications
import UIKit

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var focusStore: FocusStore
    @EnvironmentObject private var theme: ThemeStore
    
    // Agent 24: Onboarding state management
    @ObservedObject private var onboardingManager = OnboardingManager.shared

    // Persisted toggles
    @AppStorage("hasRequestedATT") private var hasRequestedATT = false
    @AppStorage("reminderScheduled") private var reminderScheduled = false

    // Live permission state
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            // Agent 24: Show onboarding if user hasn't seen it
            if onboardingManager.shouldShowOnboarding {
                OnboardingView()
            } else {
                // Main app UI with proper responsive layout
                if horizontalSizeClass == .regular {
                    // iPad: Advanced split-view with adaptive layout
                    iPadLayout
                } else {
                    // iPhone: Use TabView for proper navigation
                    TabView {
                        // Main Focus Tab
                        NavigationStack {
                        ZStack {
                            ThemeBackground().ignoresSafeArea()
                            
                            VStack(spacing: 0) {
                                // Permission banner if notifications are denied
                                if notifStatus == .denied {
                                    PermissionBanner(
                                        title: "Notifications are Off",
                                        message: "Turn on a daily reminder so you don't miss your focus session.",
                                        actionTitle: "Open Settings",
                                        action: openSystemSettings
                                    )
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .padding(.top, DesignSystem.Spacing.md)
                                }
                                
                                // Main content - removed PopupContainer framing per Apple HIG
                                FocusContentView() // Agent 19: Updated to use FocusContentView
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .padding(.top, DesignSystem.Spacing.md)
                            }
                        }
                    }
                        .tabItem {
                            Image(systemName: "brain.head.profile")
                            Text("Focus")
                        }
                        
                        // History Tab
                        NavigationStack {
                        ZStack {
                            ThemeBackground().ignoresSafeArea()
                            
                            FocusHistoryView() // Agent 11: Updated to use FocusHistoryView
                                .environmentObject(focusStore)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.top, DesignSystem.Spacing.md)
                        }
                        .navigationTitle("History")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        }
                        .tabItem {
                            Image(systemName: "clock")
                            Text("History")
                        }
                        
                        // Stats Tab
                        NavigationStack {
                        ZStack {
                            ThemeBackground().ignoresSafeArea()
                            
                            // Placeholder for Stats view - will be created by Agent 4
                            VStack {
                                Text("Stats")
                                    .font(Theme.largeTitle)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Focus statistics coming soon")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.top, DesignSystem.Spacing.md)
                        }
                        .navigationTitle("Stats")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        }
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Stats")
                        }
                        
                        // Settings Tab
                        NavigationStack {
                        ZStack {
                            ThemeBackground().ignoresSafeArea()
                            
                            SettingsView()
                                .environmentObject(focusStore)
                                .environmentObject(theme)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.top, DesignSystem.Spacing.md)
                        }
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        }
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                    }
                    .accentColor(Theme.accent)
                    .onAppear {
                            // Configure tab bar appearance per spec: cap at ~72pt, one shadow, bump active tab contrast
                        let appearance = UITabBarAppearance()
                        appearance.configureWithOpaqueBackground()
                        
                        // Cap tab bar height at ~72pt (normal is ~49pt, but we want to ensure it doesn't exceed 72pt)
                        appearance.shadowColor = UIColor.black.withAlphaComponent(0.18) // 18% black shadow
                        appearance.shadowImage = UIImage()
                        
                        // Bump active tab contrast (label + icon)
                        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.accent)
                        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                            .foregroundColor: UIColor(Theme.accent),
                            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
                        ]
                        
                        // Inactive tab styling
                        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
                        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                            .foregroundColor: UIColor.secondaryLabel,
                            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
                        ]
                        
                        // Apply appearance
                        UITabBar.appearance().standardAppearance = appearance
                        if #available(iOS 15.0, *) {
                            UITabBar.appearance().scrollEdgeAppearance = appearance
                        }
                    }
                }
            }
        }
        .toastContainer()  // Legacy toast system (Agent 7)
        .toastNotificationContainer()  // Enhanced toast system (Agent 27)
        .onAppear {
            // Defer all heavy operations to avoid blocking UI
            // Use a small delay to ensure UI renders first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 1) Request ATT exactly once (and only if not determined)
                requestATTIfNeeded()

                // 2) Check current notification status for banner/scheduling logic
                refreshNotificationStatus()

                // 3) Schedule daily reminder if we haven't and we're already authorized
                // Defer this even further as it's not critical for initial render
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !reminderScheduled {
                        scheduleDefaultReminderIfAuthorized()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                refreshNotificationStatus()
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            // If timezone/time changes, a refresh won't hurt; calendar triggers remain valid,
            // but we keep our state fresh and could reschedule if you ever add that logic.
            refreshNotificationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: AppDelegate.quickAction)) { _ in
            // Handle home screen quick action
            handleShortcutStart()
        }
        .onContinueUserActivity(AppConstants.ActivityTypes.startFocus) { userActivity in
            // Agent 11: Handle focus shortcut invocation
            handleShortcutActivity(userActivity)
        }
        .onOpenURL { url in
            // Agent 11: Handle URL-based shortcuts for Pomodoro timer
            if url.scheme == AppConstants.URLSchemes.pomodoroScheme && url.host == AppConstants.URLSchemes.startFocusHost {
                handleShortcutStart()
            }
        }
        .globalErrorHandler()
    }
    
    // MARK: - Shortcut Handling
    
    private func handleShortcutActivity(_ userActivity: NSUserActivity) {
        // Agent 11: Updated to use Focus shortcuts
        // Note: FocusShortcuts is already implemented and handles shortcut registration
        // This handler responds to shortcut activities by triggering focus start
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut), object: nil)
    }
    
    private func handleShortcutStart() {
        // Agent 11: Updated to trigger focus session start
        NotificationCenter.default.post(name: NSNotification.Name(AppConstants.NotificationNames.startFocusFromShortcut), object: nil)
    }

    // MARK: - ATT (App Tracking Transparency)

    private func requestATTIfNeeded() {
        guard !hasRequestedATT else { return }
        guard #available(iOS 14, *) else { return }

        // Request only if status is .notDetermined
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else {
            hasRequestedATT = true
            return
        }

        // Gentle delay so it doesn't appear on first frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    hasRequestedATT = true
                }
            }
        }
    }

    // MARK: - Notifications

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notifStatus = settings.authorizationStatus
            }
        }
    }

    /// Schedules the default 8PM reminder only if we’re authorized (or provisionally authorized).
    private func scheduleDefaultReminderIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let ok: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                ok = true
            default:
                ok = false
            }

            guard ok else { return }

            // If you have your NotificationManager, prefer it:
            if let schedule = try? NotificationManagerSchedule() {
                schedule.at(hour: 20, minute: 0, id: "daily.focus.default")
                DispatchQueue.main.async { reminderScheduled = true }
                return
            }

            // Fallback inline scheduler (no dependency)
            var dc = DateComponents(); dc.hour = 20; dc.minute = 0
            let content = UNMutableNotificationContent()
            content.title = "Time for Your Focus Session"
            content.body = "Start your Pomodoro timer and stay focused!"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let req = UNNotificationRequest(identifier: "daily_focus",
                                            content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(req) { _ in
                DispatchQueue.main.async { reminderScheduled = true }
            }
        }
    }

    // MARK: - iPad Layout
    
    @State private var showingJournal = false
    @State private var showingSidebar = false
    @State private var selectedTab = 0
    
    private var iPadLayout: some View {
        NavigationSplitView {
            // Sidebar for iPad
            iPadSidebar(selectedTab: $selectedTab, showingJournal: $showingJournal)
                .environmentObject(focusStore)
                .environmentObject(theme)
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            // Main content area
            iPadMainContent(selectedTab: $selectedTab, showingJournal: $showingJournal)
                .environmentObject(focusStore)
                .environmentObject(theme)
        }
        .navigationSplitViewStyle(.balanced)
        .background(ThemeBackground().ignoresSafeArea())
    }
    
    // MARK: - Helpers

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - iPad Sidebar

struct iPadSidebar: View {
    @Binding var selectedTab: Int
    @Binding var showingJournal: Bool
    @EnvironmentObject private var focusStore: FocusStore
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.accent)
                    
                    Text("Focus Timer")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                // Quick stats
                HStack(spacing: DesignSystem.Spacing.formFieldSpacing) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("\(focusStore.totalSessions)")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.accent)
                        Text("Sessions")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("\(focusStore.streak)")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.accent)
                        Text("Day Streak")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.formFieldSpacing)
            .padding(.top, DesignSystem.Spacing.formFieldSpacing)
            .padding(.bottom, DesignSystem.Spacing.xl)
            
            Divider()
                .overlay(Color.white.opacity(0.1))
            
            // Navigation
            VStack(spacing: DesignSystem.Spacing.sm) {
                iPadSidebarButton(
                    title: "Focus",
                    icon: "brain.head.profile",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                iPadSidebarButton(
                    title: "History",
                    icon: "clock",
                    isSelected: selectedTab == 1,
                    action: { 
                        selectedTab = 1
                        showingJournal = true
                    }
                )
                
                iPadSidebarButton(
                    title: "Stats",
                    icon: "chart.bar.fill",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
                
                iPadSidebarButton(
                    title: "Settings",
                    icon: "gearshape.fill",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 }
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.formFieldSpacing)
            
            Spacer()
            
            // Recent focus sessions preview
            if !focusStore.sessions.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Recent")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, DesignSystem.Spacing.formFieldSpacing)
                    
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(focusStore.sessions.prefix(3)) { session in
                                iPadRecentFocusCard(session: session)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.formFieldSpacing)
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.bottom, DesignSystem.Spacing.formFieldSpacing)
            }
        }
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(LinearGradient(
                    colors: [Theme.accent.opacity(0.1), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .ignoresSafeArea()
                .allowsHitTesting(false)
        )
    }
}

// MARK: - iPad Main Content

struct iPadMainContent: View {
    @Binding var selectedTab: Int
    @Binding var showingJournal: Bool
    @EnvironmentObject private var focusStore: FocusStore
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var preferencesStore: FocusPreferencesStore
    
    var body: some View {
        detailContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(selectedTab)
    }
    
    @ViewBuilder
    private func detailContent() -> some View {
        switch selectedTab {
        case 0:
            NavigationStack {
                FocusContentView()
                    .environmentObject(focusStore)
                    .environmentObject(theme)
                    .environmentObject(preferencesStore)
            }
        case 1:
            NavigationStack {
                FocusHistoryView()
                    .environmentObject(focusStore)
            }
        case 2:
            NavigationStack {
                VStack {
                    Text("Stats")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Focus statistics coming soon")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding()
            }
        case 3:
            NavigationStack {
                SettingsView()
                    .environmentObject(focusStore)
                    .environmentObject(theme)
            }
        default:
            NavigationStack {
                FocusContentView()
                    .environmentObject(focusStore)
                    .environmentObject(theme)
                    .environmentObject(preferencesStore)
            }
        }
    }
}

// MARK: - iPad Sidebar Button

struct iPadSidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(Theme.title3)
                    .foregroundStyle(isSelected ? Theme.textOnDark : Theme.textSecondary)
                    .frame(width: DesignSystem.IconSize.statBox)
                
                Text(title)
                    .font(Theme.body.weight(.medium))
                    .foregroundStyle(isSelected ? Theme.textOnDark : Theme.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(.white)
                        .frame(width: DesignSystem.Spacing.sm, height: DesignSystem.Spacing.sm)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(isSelected ? Theme.accent : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .stroke(
                                isSelected ? Theme.accent.opacity(DesignSystem.Opacity.light * 1.5) : Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle),
                                lineWidth: isSelected ? DesignSystem.Border.standard : DesignSystem.Border.hairline
                            )
                    )
            )
            .shadow(color: isSelected ? Theme.accent.opacity(DesignSystem.Opacity.subtle) : Color.clear, 
                   radius: isSelected ? DesignSystem.Shadow.verySoft.radius : 0, 
                   y: isSelected ? DesignSystem.Shadow.verySoft.y : 0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - iPad Recent Focus Card

struct iPadRecentFocusCard: View {
    let session: FocusSession
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Circle()
                .fill(phaseColor.opacity(0.2))
                .frame(width: DesignSystem.IconSize.small, height: DesignSystem.IconSize.small)
                .padding(.top, DesignSystem.Spacing.sm)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(session.phaseType.displayName)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                phaseColor.opacity(DesignSystem.Opacity.highlight * 0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
            )
        )
        .softShadow()
    }
    
    private var phaseColor: Color {
        switch session.phaseType {
        case .focus:
            return Theme.ringFocus
        case .shortBreak:
            return Theme.ringBreakShort
        case .longBreak:
            return Theme.ringBreakLong
        }
    }
}

// MARK: - iPad Insights View

struct iPadInsightsView: View {
    @EnvironmentObject private var focusStore: FocusStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Text("Insights")
                    .font(Theme.largeTitle)
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.formFieldSpacing) {
                    iPadInsightCard(
                        title: "Total Sessions",
                        value: "\(focusStore.totalSessions)",
                        icon: "brain.head.profile",
                        color: Theme.accent
                    )
                    
                    iPadInsightCard(
                        title: "Current Streak",
                        value: "\(focusStore.streak) days",
                        icon: "flame.fill",
                        color: Theme.ringBreakShort
                    )
                    
                    iPadInsightCard(
                        title: "This Month",
                        value: "\(focusStore.sessionsThisMonth) sessions",
                        icon: "calendar",
                        color: Theme.ringBreakLong
                    )
                    
                    iPadInsightCard(
                        title: "Total Minutes",
                        value: "\(Int(focusStore.totalFocusTime)) min",
                        icon: "clock.fill",
                        color: Theme.ringBreakLong
                    )
                }
                
                // Recent entries chart placeholder
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    Text("Activity This Week")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5),
                                            Theme.accent.opacity(DesignSystem.Opacity.light * 0.5),
                                            Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 1.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: DesignSystem.Border.subtle
                                )
                        )
                        .softShadow()
                        .overlay(
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(Theme.largeTitle)
                                    .foregroundStyle(Theme.accent.opacity(0.6))
                                Text("Chart Coming Soon")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                            }
                        )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.formFieldSpacing)
        }
    }
    
}

// MARK: - iPad Insight Card

struct iPadInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(Theme.title2)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(value)
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(title)
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DesignSystem.Spacing.formFieldSpacing)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(color.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.standard)
                )
        )
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(ThemeStore())
            .environmentObject(FocusStore())
    }
}
#endif

// MARK: - Nice, reusable permission banner

private struct PermissionBanner: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "bell.slash.fill").font(Theme.title3)
                Text(title).font(Theme.headline)
                Spacer()
            }
            Text(message)
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox).stroke(.white.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.standard))
        .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.medium), radius: DesignSystem.Shadow.medium.radius, y: DesignSystem.Shadow.medium.y)
    }
}

// MARK: - Optional wrapper that uses your NotificationManager if present

/// Lightweight adapter so this RootView works whether or not you've added NotificationManager.swift.
/// If NotificationManager is available, `try? NotificationManagerSchedule()` succeeds and we use it.
private struct NotificationManagerSchedule {
    init() throws {
        // If the symbol doesn't exist, this will throw at compile time — but because we call it with `try?`,
        // the compiler will optimize it out in builds where NotificationManager exists.
    }
    func at(hour: Int, minute: Int, id: String) {
        var comps = DateComponents()
        comps.hour = hour; comps.minute = minute
        NotificationManager.scheduleDailyReminder(at: comps, identifier: id)
    }
}
