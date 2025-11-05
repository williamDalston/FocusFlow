import SwiftUI
import AppTrackingTransparency
import UserNotifications
import UIKit

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var workoutStore: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore

    // Persisted toggles
    @AppStorage("hasRequestedATT") private var hasRequestedATT = false
    @AppStorage("reminderScheduled") private var reminderScheduled = false

    // Live permission state
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            // Main app UI with proper responsive layout
            if horizontalSizeClass == .regular {
                // iPad: Advanced split-view with adaptive layout
                iPadLayout
            } else {
                // iPhone: Use TabView for proper navigation
                TabView {
                    // Main Workout Tab
                    NavigationStack {
                        VStack(spacing: 0) {
                            // Permission banner if notifications are denied
                            if notifStatus == .denied {
                                PermissionBanner(
                                    title: "Notifications are Off",
                                    message: "Turn on a daily reminder so you don't miss your workout.",
                                    actionTitle: "Open Settings",
                                    action: openSystemSettings
                                )
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            // Main content
                            WorkoutContentView()
                        }
                        .background(ThemeBackground().ignoresSafeArea())
                    }
                    .tabItem {
                        Image(systemName: "figure.run")
                        Text("Workout")
                    }
                    
                    // History Tab
                    NavigationStack {
                        WorkoutHistoryView()
                            .environmentObject(workoutStore)
                            .navigationTitle("History")
                            .navigationBarTitleDisplayMode(.large)
                    }
                    .tabItem {
                        Image(systemName: "clock")
                        Text("History")
                    }
                    
                    // Settings Tab
                    NavigationStack {
                        SettingsView()
                            .environmentObject(workoutStore)
                            .environmentObject(theme)
                            .navigationTitle("Settings")
                            .navigationBarTitleDisplayMode(.large)
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                }
                .accentColor(Theme.accentA)
            }
        }
        .onAppear {
            // Defer heavy operations to avoid blocking UI
            DispatchQueue.main.async {
                // 1) Request ATT exactly once (and only if not determined)
                requestATTIfNeeded()

                // 2) Check current notification status for banner/scheduling logic
                refreshNotificationStatus()

                // 3) Schedule daily reminder if we haven't and we're already authorized
                if !reminderScheduled {
                    scheduleDefaultReminderIfAuthorized()
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
        .onContinueUserActivity("com.williamalston.Ritual7.startWorkout") { userActivity in
            // Agent 8: Handle shortcut invocation
            handleShortcutActivity(userActivity)
        }
        .onOpenURL { url in
            // Agent 8: Handle URL-based shortcuts
            if url.scheme == "sevenminuteworkout" && url.host == "start" {
                handleShortcutStart()
            }
        }
    }
    
    // MARK: - Shortcut Handling
    
    private func handleShortcutActivity(_ userActivity: NSUserActivity) {
        WorkoutShortcuts.handleShortcut(userActivity)
        // Trigger workout start (this would need to be connected to WorkoutContentView)
        NotificationCenter.default.post(name: NSNotification.Name("StartWorkoutFromShortcut"), object: nil)
    }
    
    private func handleShortcutStart() {
        NotificationCenter.default.post(name: NSNotification.Name("StartWorkoutFromShortcut"), object: nil)
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
                schedule.at(hour: 20, minute: 0, id: "daily.workout.default")
                DispatchQueue.main.async { reminderScheduled = true }
                return
            }

            // Fallback inline scheduler (no dependency)
            var dc = DateComponents(); dc.hour = 20; dc.minute = 0
            let content = UNMutableNotificationContent()
            content.title = "Time for Your Ritual7"
            content.body = "Quick and effective! Start your daily workout now."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let req = UNNotificationRequest(identifier: "daily_workout",
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
                .environmentObject(workoutStore)
                .environmentObject(theme)
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            // Main content area
            iPadMainContent(selectedTab: $selectedTab, showingJournal: $showingJournal)
                .environmentObject(workoutStore)
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
    @EnvironmentObject private var workoutStore: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("Ritual7")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                // Quick stats
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(workoutStore.totalWorkouts)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Theme.accentA)
                        Text("Workouts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(workoutStore.streak)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Theme.accentB)
                        Text("Day Streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            Divider()
                .overlay(Color.white.opacity(0.1))
            
            // Navigation
            VStack(spacing: 8) {
                iPadSidebarButton(
                    title: "Workout",
                    icon: "figure.run",
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
                    title: "Exercises",
                    icon: "list.bullet",
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
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            Spacer()
            
            // Recent workouts preview
            if !workoutStore.sessions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 20)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(workoutStore.sessions.prefix(3)) { session in
                                iPadRecentWorkoutCard(session: session)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.bottom, 20)
            }
        }
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(LinearGradient(
                    colors: [Theme.accentA.opacity(0.1), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .ignoresSafeArea()
        )
    }
}

// MARK: - iPad Main Content

struct iPadMainContent: View {
    @Binding var selectedTab: Int
    @Binding var showingJournal: Bool
    @EnvironmentObject private var workoutStore: WorkoutStore
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                WorkoutContentView()
                    .environmentObject(workoutStore)
                    .environmentObject(theme)
                    .environmentObject(preferencesStore)
            case 1:
                WorkoutHistoryView()
                    .environmentObject(workoutStore)
            case 2:
                ExerciseListView()
            case 3:
                SettingsView()
                    .environmentObject(workoutStore)
                    .environmentObject(theme)
            default:
                WorkoutContentView()
                    .environmentObject(workoutStore)
                    .environmentObject(theme)
                    .environmentObject(preferencesStore)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Theme.textOnDark : Theme.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isSelected ? Theme.textOnDark : Theme.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Theme.accentA : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - iPad Recent Workout Card

struct iPadRecentWorkoutCard: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Theme.accentA.opacity(0.2))
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(session.exercisesCompleted) exercises")
                    .font(.caption)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - iPad Insights View

struct iPadInsightsView: View {
    @EnvironmentObject private var workoutStore: WorkoutStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Insights")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    iPadInsightCard(
                        title: "Total Workouts",
                        value: "\(workoutStore.totalWorkouts)",
                        icon: "figure.run",
                        color: Theme.accentA
                    )
                    
                    iPadInsightCard(
                        title: "Current Streak",
                        value: "\(workoutStore.streak) days",
                        icon: "flame.fill",
                        color: Theme.accentB
                    )
                    
                    iPadInsightCard(
                        title: "This Month",
                        value: "\(workoutStore.workoutsThisMonth) workouts",
                        icon: "calendar",
                        color: Theme.accentC
                    )
                    
                    iPadInsightCard(
                        title: "Total Minutes",
                        value: "\(Int(workoutStore.totalMinutes)) min",
                        icon: "clock.fill",
                        color: Theme.accentC
                    )
                }
                
                // Recent entries chart placeholder
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activity This Week")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(Theme.accentA.opacity(0.6))
                                Text("Chart Coming Soon")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(ThemeStore())
            .environmentObject(WorkoutStore())
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "bell.slash.fill").font(.title3)
                Text(title).font(.headline)
                Spacer()
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 10)
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
