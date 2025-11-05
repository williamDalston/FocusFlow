import SwiftUI
import UIKit
import UserNotifications
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var workoutStore: WorkoutStore

    @State private var showResetConfirm = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []

    // Appearance
    @State private var matchSystem: Bool = true
    @State private var forcedScheme: ColorScheme = .dark

    // Sound & Vibration
    @StateObject private var soundManager = SoundManager.shared

    // Reminders - Agent 7: Enhanced notification settings
    @State private var reminderEnabled: Bool = false
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined
    @AppStorage("reminderHour") private var reminderHour: Int = 20
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @AppStorage("streakReminderEnabled") private var streakReminderEnabled: Bool = false
    @AppStorage("noWorkoutNudgeEnabled") private var noWorkoutNudgeEnabled: Bool = false
    @AppStorage("weeklySummaryEnabled") private var weeklySummaryEnabled: Bool = false
    @AppStorage("quietHoursStart") private var quietHoursStart: Int = 22 // 10 PM
    @AppStorage("quietHoursEnd") private var quietHoursEnd: Int = 7 // 7 AM
    @AppStorage("quietHoursEnabled") private var quietHoursEnabled: Bool = false
    
    // Watch connectivity (only used on iPad)
    @StateObject private var watchManager = WatchSessionManager.shared
    
    // HealthKit
    @StateObject private var healthKitStore = HealthKitStore.shared
    @State private var showHealthKitPermissions = false

    var body: some View {
        NavigationStack {
            Group {
                if horizontalSizeClass == .regular {
                    // iPad layout - full settings list
                    List {
                        appearanceSection
                        soundSection
                        watchSection
                        reminderSection
                        healthKitSection
                        dataSection
                        aboutSection
                        dangerSection
                    }
                    .environment(\.defaultMinListHeaderHeight, 8)
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(ThemeBackground())
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.large)
                } else {
                    // iPhone layout
                    List {
                        appearanceSection
                        soundSection
                        reminderSection
                        healthKitSection
                        dataSection
                        aboutSection
                        dangerSection
                    }
                    .environment(\.defaultMinListHeaderHeight, 8)
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(ThemeBackground())
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                dismiss()
                                Haptics.tap()
                            }
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textOnDark)
                        }
                    }
                }
            }
            .alert("Reset All Data?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { workoutStore.reset() }
            } message: {
                Text("This will permanently remove all your workout sessions and your streak.")
            }
            .sheet(isPresented: $showShare) {
                ActivityView(activityItems: shareItems).ignoresSafeArea()
            }
            .sheet(isPresented: $showHealthKitPermissions) {
                HealthKitPermissionsView()
            }
            .onAppear {
                // Appearance seed
                if let scheme = theme.colorScheme {
                    matchSystem = false
                    forcedScheme = scheme
                } else {
                    matchSystem = true
                }
                // Reminder seed
                refreshNotificationStatus()
                readCurrentReminderScheduled()
                // HealthKit status
                healthKitStore.checkAuthorizationStatus()
            }
            // iOS 16+ compatible onChange
            .onChange(of: matchSystem) { _ in
                theme.colorScheme = matchSystem ? nil : forcedScheme
            }
            .onChange(of: forcedScheme) { _ in
                if !matchSystem { theme.colorScheme = forcedScheme }
            }
            .onChange(of: reminderEnabled) { _ in
                if reminderEnabled {
                    ensureReminderPermissionsThenSchedule()
                } else {
                    cancelDailyReminder()
                }
            }
            .onChange(of: reminderHour) { _ in
                if reminderEnabled { scheduleDailyReminder(hour: reminderHour, minute: reminderMinute) }
            }
            .onChange(of: reminderMinute) { _ in
                if reminderEnabled { scheduleDailyReminder(hour: reminderHour, minute: reminderMinute) }
            }
            .onChange(of: streakReminderEnabled) { _ in
                if streakReminderEnabled && workoutStore.streak > 0 {
                    var comps = DateComponents()
                    comps.hour = reminderHour + 2 // 2 hours after main reminder
                    comps.minute = reminderMinute
                    NotificationManager.scheduleStreakReminder(at: comps, streak: workoutStore.streak)
                } else {
                    NotificationManager.cancelStreakReminder()
                }
            }
            .onChange(of: noWorkoutNudgeEnabled) { _ in
                if noWorkoutNudgeEnabled {
                    var comps = DateComponents()
                    comps.hour = reminderHour + 4 // 4 hours after main reminder
                    comps.minute = reminderMinute
                    NotificationManager.scheduleNoWorkoutNudge(at: comps)
                } else {
                    NotificationManager.cancelNoWorkoutNudge()
                }
            }
            .onChange(of: weeklySummaryEnabled) { _ in
                if weeklySummaryEnabled {
                    // Schedule for Sunday at 8 PM
                    NotificationManager.scheduleWeeklySummary(on: 1, hour: 20, minute: 0)
                } else {
                    NotificationManager.cancelWeeklySummary()
                }
            }
            .onChange(of: soundManager.soundEnabled) { _ in
                soundManager.saveSettings()
            }
            .onChange(of: soundManager.vibrationEnabled) { _ in
                soundManager.saveSettings()
            }
        }
    }

    // MARK: - Sections

    private var soundSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Sound Effects")
                            .font(Theme.body)
                        Text("Play sounds during workout transitions and countdown.")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $soundManager.soundEnabled)
                        .tint(.white)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Vibration")
                            .font(Theme.body)
                        Text("Haptic feedback during workout.")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $soundManager.vibrationEnabled)
                        .tint(.white)
                }
            }
        } header: {
            Text("Sound & Haptics").textCase(.none)
        }
    }

    private var appearanceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Color Theme Selector
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Text("Color Theme")
                            .font(Theme.body)
                        Spacer()
                        // Color preview
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Circle()
                                .fill(Theme.accentA)
                                .frame(width: DesignSystem.Spacing.md, height: DesignSystem.Spacing.md)
                            Circle()
                                .fill(Theme.accentB)
                                .frame(width: DesignSystem.Spacing.md, height: DesignSystem.Spacing.md)
                            Circle()
                                .fill(Theme.accentC)
                                .frame(width: DesignSystem.Spacing.md, height: DesignSystem.Spacing.md)
                        }
                    }
                    
                    Picker("Color Theme", selection: $theme.colorTheme) {
                        ForEach(Theme.ColorTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.white)
                    .onChange(of: theme.colorTheme) { newTheme in
                        Haptics.gentle()
                        // Force UI refresh
                        theme.objectWillChange.send()
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Match iOS Appearance")
                            .font(Theme.body)
                        Text("Use your device's Light/Dark setting. Turn off to choose manually.")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $matchSystem)
                        .tint(.white)
                }

                if !matchSystem {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Picker("Appearance", selection: $forcedScheme) {
                            Text("Light").tag(ColorScheme.light)
                            Text("Dark").tag(ColorScheme.dark)
                        }
                        .pickerStyle(.segmented)

                        // Live preview so users instantly "get it".
                        GlassCard(material: .regularMaterial) {
                            HStack(spacing: 12) {
                                Image(systemName: forcedScheme == .dark ? "moon.fill" : "sun.max.fill")
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(forcedScheme == .dark ? "Dark Mode Preview" : "Light Mode Preview")
                                        .font(.headline)
                                    Text("Cards, text, and accents adapt to this look.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                        }
                        .environment(\.colorScheme, forcedScheme)
                        
                        // Color theme preview
                        GlassCard(material: .regularMaterial) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Color Theme Preview")
                                        .font(.headline)
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Circle().fill(Theme.accentA).frame(width: 8, height: 8)
                                        Circle().fill(Theme.accentB).frame(width: 8, height: 8)
                                        Circle().fill(Theme.accentC).frame(width: 8, height: 8)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.accentA)
                                        .frame(height: 20)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.accentB)
                                        .frame(height: 20)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.accentC)
                                        .frame(height: 20)
                                }
                                
                                Text("This is how your app will look with the selected theme.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: theme.colorTheme)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        } header: {
            Text("Appearance").textCase(.none)
        } footer: {
            Text("You can always switch back to matching iOS automatically.")
        }
    }
    
    private var watchSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Watch connection status
                HStack {
                    Image(systemName: "applewatch")
                        .font(.title2)
                        .foregroundStyle(watchManager.isWatchConnected ? Theme.accentA : .secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apple Watch")
                            .font(.body.weight(.semibold))
                        
                        Text(watchStatusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if watchManager.isWatchConnected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.orange)
                    }
                }
                
                // Watch features info
                if watchManager.isWatchConnected {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Watch Features:")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.accentA)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "mic.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.accentB)
                                Text("Voice-to-text workout notes")
                                    .font(.caption2)
                            }
                            
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundStyle(Theme.accentB)
                                Text("Quick preset buttons")
                                    .font(.caption2)
                            }
                            
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.caption)
                                    .foregroundStyle(Theme.accentB)
                                Text("Live streak on watch face")
                                    .font(.caption2)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                
                // Sync button
                if watchManager.isWatchConnected && watchManager.isReachable {
                    Button("Sync with Watch") {
                        watchManager.sendEntriesToWatch()
                        watchManager.updateWatchComplications()
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textOnDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.accentA)
                    )
                }
            }
        } header: {
            Text("Apple Watch")
        }
    }

    private var reminderSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Toggle(isOn: $reminderEnabled) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs * 0.5) {
                            Text("Daily Workout Reminder")
                                .font(Theme.body)
                            Text("Get reminded to complete your daily 7-minute workout.")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.white)

                    Spacer(minLength: DesignSystem.Spacing.sm)

                    statusChip
                }

                if reminderEnabled {
                    HStack {
                        Text("Time")
                            .font(Theme.body)
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date() },
                                set: { date in
                                    let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    reminderHour = c.hour ?? 20
                                    reminderMinute = c.minute ?? 0
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(.white)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xs * 0.5)
                    
                    Divider()
                    
                    // Agent 7: Additional notification options
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Toggle(isOn: $streakReminderEnabled) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs * 0.5) {
                                Text("Streak Reminders")
                                    .font(Theme.body)
                                Text("Get notified if you haven't worked out today and have an active streak.")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.white)
                        
                        Toggle(isOn: $noWorkoutNudgeEnabled) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs * 0.5) {
                                Text("Gentle Nudges")
                                    .font(Theme.body)
                                Text("Receive a gentle reminder if you haven't worked out today.")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.white)
                        
                        Toggle(isOn: $weeklySummaryEnabled) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs * 0.5) {
                                Text("Weekly Progress Summary")
                                    .font(Theme.body)
                                Text("Get a weekly summary of your workout progress every Sunday.")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.white)
                    }
                }
                
                // Quiet Hours
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $quietHoursEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quiet Hours")
                                .font(.body.weight(.semibold))
                            Text("Don't receive notifications during these hours.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.white)
                    
                    if quietHoursEnabled {
                        HStack {
                            Text("From")
                                .foregroundStyle(.secondary)
                            Spacer()
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { Calendar.current.date(from: DateComponents(hour: quietHoursStart, minute: 0)) ?? Date() },
                                    set: { date in
                                        let c = Calendar.current.dateComponents([.hour], from: date)
                                        quietHoursStart = c.hour ?? 22
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .tint(.white)
                            
                            Text("To")
                                .foregroundStyle(.secondary)
                            
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { Calendar.current.date(from: DateComponents(hour: quietHoursEnd, minute: 0)) ?? Date() },
                                    set: { date in
                                        let c = Calendar.current.dateComponents([.hour], from: date)
                                        quietHoursEnd = c.hour ?? 7
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .tint(.white)
                        }
                    }
                }

                if notifStatus == .denied {
                    Button {
                        openSystemSettings()
                    } label: {
                        Label("Open iOS Settings", systemImage: "gearshape")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        } header: {
            Text("Reminders & Notifications").textCase(.none)
        } footer: {
            Text(footerCopyForNotifications())
        }
    }

    private var healthKitSection: some View {
        Section {
            if healthKitStore.isAvailable {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: DesignSystem.IconSize.large))
                        .foregroundStyle(
                            healthKitStore.isAuthorized 
                                ? LinearGradient(
                                    colors: [Theme.accentA, Theme.accentB],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.secondary, Color.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: DesignSystem.IconSize.large, height: DesignSystem.IconSize.large)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Health Integration")
                            .font(.body.weight(DesignSystem.Typography.headlineWeight))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text(healthKitStatusText)
                            .font(.caption.weight(DesignSystem.Typography.captionWeight))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if healthKitStore.isAuthorized {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: DesignSystem.IconSize.medium))
                            .foregroundStyle(.green)
                            .accessibilityLabel("Connected")
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: DesignSystem.IconSize.medium))
                            .foregroundStyle(.orange)
                            .accessibilityLabel("Not Connected")
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Health Integration, \(healthKitStatusText)")
                
                if !healthKitStore.isAuthorized {
                    Button {
                        showHealthKitPermissions = true
                    } label: {
                        Label("Connect with Health", systemImage: "heart.fill")
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Connect with Health")
                    .accessibilityHint("Double tap to connect your workouts with Apple Health")
                } else {
                    Button {
                        openHealthSettings()
                    } label: {
                        Label("Manage in Settings", systemImage: "gearshape")
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Manage in Settings")
                    .accessibilityHint("Double tap to open Health app settings")
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("What's synced:")
                        .font(.caption.weight(DesignSystem.Typography.headlineWeight))
                        .foregroundStyle(Theme.accentA)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        SyncFeatureRow(
                            icon: "figure.run",
                            text: "Workout sessions"
                        )
                        
                        SyncFeatureRow(
                            icon: "flame.fill",
                            text: "Calories burned"
                        )
                        
                        SyncFeatureRow(
                            icon: "clock.fill",
                            text: "Exercise minutes"
                        )
                        
                        SyncFeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            text: "Activity rings"
                        )
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            } else {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: DesignSystem.IconSize.large))
                        .foregroundStyle(.secondary)
                        .frame(width: DesignSystem.IconSize.large, height: DesignSystem.IconSize.large)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Health Integration")
                            .font(.body.weight(DesignSystem.Typography.headlineWeight))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("HealthKit is not available on this device")
                            .font(.caption.weight(DesignSystem.Typography.captionWeight))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Health Integration, HealthKit is not available on this device")
            }
        } header: {
            Text("Health Integration").textCase(.none)
        } footer: {
            if healthKitStore.isAvailable {
                Text("Your workouts are automatically synced to Apple Health and Activity apps. Your health data is private and secure.")
            } else {
                Text("HealthKit is only available on iOS devices.")
            }
        }
    }
    
    // MARK: - Sync Feature Row Helper
    
    private struct SyncFeatureRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: DesignSystem.IconSize.small))
                    .foregroundStyle(Theme.accentB)
                    .frame(width: DesignSystem.IconSize.small, height: DesignSystem.IconSize.small)
                
                Text(text)
                    .font(.caption2.weight(DesignSystem.Typography.bodyWeight))
                    .foregroundStyle(Theme.textPrimary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(text)
        }
    }
    
    private var dataSection: some View {
        Section {
            Button {
                exportJSON()
            } label: {
                Label("Export Data (JSON)", systemImage: "doc.badge.arrow.up")
            }

            Button {
                exportCSV()
            } label: {
                Label("Export Data (CSV)", systemImage: "tablecells")
            }
        } header: {
            Text("Data").textCase(.none)
        } footer: {
            Text("Exports include your workout sessions with timestamps. You can import into other apps or keep a personal backup.")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                PrivacyView().navigationTitle("Privacy")
            } label: {
                Label("Privacy Policy", systemImage: "lock.shield")
            }

            Button {
                requestReview()
            } label: {
                Label("Rate the App", systemImage: "star.fill")
            }

            HStack {
                Label("Version", systemImage: "number.circle")
                Spacer()
                Text(Bundle.main.prettyVersionString)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About").textCase(.none)
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Reset All Data", systemImage: "trash")
            }
        } header: {
            Text("Danger Zone").textCase(.none)
        } footer: {
            Text("This permanently deletes your journal and resets your streak.")
        }
    }

    // MARK: - UI Bits

    private var statusChip: some View {
        Group {
            switch notifStatus {
            case .authorized, .provisional, .ephemeral:
                Label("On", systemImage: "checkmark.seal.fill")
                    .font(Theme.caption)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs * 0.75)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle))
            case .denied:
                Label("Off", systemImage: "bell.slash.fill")
                    .font(Theme.caption)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs * 0.75)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle))
            default:
                Label("Ask", systemImage: "questionmark.diamond.fill")
                    .font(Theme.caption)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs * 0.75)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle))
            }
        }
        .foregroundStyle(Theme.textOnDark)
    }

    // MARK: - Data Export

    private func exportJSON() {
        do {
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            let data = try enc.encode(store.entries)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("SevenMinuteWorkout.json")
            try data.write(to: url, options: .atomic)
            shareItems = [url]
            Haptics.tap()
            showShare = true
        } catch {
            print("Export JSON failed:", error.localizedDescription)
        }
    }

    private func exportCSV() {
        var csv = "date,text\n"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        for e in store.entries.sorted(by: { $0.date < $1.date }) {
            let ts = formatter.string(from: e.date)
            let escaped = e.text
                .replacingOccurrences(of: "\"", with: "\"\"")
                .replacingOccurrences(of: "\n", with: " ")
            csv += "\"\(ts)\",\"\(escaped)\"\n"
        }
        let data = Data(csv.utf8)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SevenMinuteWorkout.csv")
        do {
            try data.write(to: url, options: .atomic)
            shareItems = [url]
            Haptics.tap()
            showShare = true
        } catch {
            print("Export CSV failed:", error.localizedDescription)
        }
    }

    // MARK: - Notifications

    private func ensureReminderPermissionsThenSchedule() {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            if s.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async {
                        refreshNotificationStatus()
                        if granted {
                            scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                        } else {
                            reminderEnabled = false
                        }
                    }
                }
            } else if s.authorizationStatus == .authorized || s.authorizationStatus == .provisional || s.authorizationStatus == .ephemeral {
                DispatchQueue.main.async {
                    scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                }
            } else {
                DispatchQueue.main.async {
                    reminderEnabled = false
                }
            }
        }
    }

    private func scheduleDailyReminder(hour: Int, minute: Int) {
        // Remove existing request so this is idempotent
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_workout"])

        var comps = DateComponents()
        comps.hour = hour; comps.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Time for Your 7-Minute Workout"
        content.body = "Quick and effective! Start your daily workout now."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "daily_workout", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { err in
            if let err = err { print("Schedule error:", err) }
        }
    }
    
    private var watchStatusText: String {
        if !watchManager.isWatchConnected {
            return "No Apple Watch paired"
        } else if !watchManager.isWatchAppInstalled {
            return "Watch app not installed"
        } else if !watchManager.isReachable {
            return "Watch not reachable"
        } else {
            return "Connected and ready"
        }
    }
    
    private var healthKitStatusText: String {
        if !healthKitStore.isAvailable {
            return "Not available on this device"
        } else if healthKitStore.isAuthorized {
            return "Connected to Health"
        } else {
            return "Not connected"
        }
    }
    
    private func openHealthSettings() {
        guard let url = URL(string: "x-apple-health://") else {
            // Fallback to general settings if Health app URL is not available
            openSystemSettings()
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            openSystemSettings()
        }
    }

    private func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_workout"])
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            DispatchQueue.main.async {
                notifStatus = s.authorizationStatus
            }
        }
    }

    private func readCurrentReminderScheduled() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            let exists = reqs.contains { $0.identifier == "daily_workout" }
            DispatchQueue.main.async {
                reminderEnabled = exists
            }
        }
    }

    private func footerCopyForNotifications() -> String {
        switch notifStatus {
        case .authorized, .provisional, .ephemeral:
            return "We’ll remind you at the time you pick. You can change this anytime."
        case .denied:
            return "Notifications are off for this app. Turn them on in iOS Settings to enable reminders."
        default:
            return "We’ll ask for permission the first time you enable reminders."
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Review

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// MARK: - UIKit share sheet wrapper
private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

// MARK: - Helpers
private extension Bundle {
    var prettyVersionString: String {
        let v = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }
}
