import SwiftUI
import UIKit
import UserNotifications
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var focusStore: FocusStore

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
    
    // Daily Motivation toggle
    @AppStorage("dailyMotivationEnabled") private var dailyMotivationEnabled = true
    
    // Agent 6: Pomodoro Timer Settings
    @StateObject private var focusPreferencesStore = FocusPreferencesStore()
    @State private var showFocusCustomization = false

    var body: some View {
        NavigationStack {
            Group {
                if horizontalSizeClass == .regular {
                    // iPad layout - full settings list
                    List {
                        appearanceSection
                        soundSection
                        pomodoroTimerSection
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
                        pomodoroTimerSection
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
                                // Ensure all settings are saved before dismissing
                                
                                // Ensure color theme is saved and applied
                                Theme.currentTheme = theme.colorTheme
                                UserDefaults.standard.set(theme.colorTheme.rawValue, forKey: "colorTheme")
                                
                                // Theme appearance settings
                                if !matchSystem {
                                    theme.colorScheme = forcedScheme
                                } else {
                                    theme.colorScheme = nil
                                }
                                
                                // Save sound/vibration settings
                                soundManager.saveSettings()
                                
                                // Force UserDefaults sync to ensure persistence
                                UserDefaults.standard.synchronize()
                                
                                // Force UI refresh for theme changes
                                theme.objectWillChange.send()
                                
                                // Provide haptic feedback
                                Haptics.tap()
                                
                                // Dismiss the view (works if presented as sheet, no-op if in tab)
                                dismiss()
                            }
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textOnDark)
                        }
                    }
                }
            }
            .alert("Reset All Data?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { focusStore.reset() }
            } message: {
                Text("This will permanently remove all your focus sessions and your streak.")
            }
            .sheet(isPresented: $showShare) {
                ActivityView(activityItems: shareItems).ignoresSafeArea()
                    .iPadOptimizedSheetPresentation()
            }
            .sheet(isPresented: $showHealthKitPermissions) {
                HealthKitPermissionsView()
                    .iPadOptimizedSheetPresentation()
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
                if streakReminderEnabled && focusStore.streak > 0 {
                    var comps = DateComponents()
                    comps.hour = reminderHour + 2 // 2 hours after main reminder
                    comps.minute = reminderMinute
                    NotificationManager.scheduleStreakReminder(at: comps, streak: focusStore.streak)
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.formFieldSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Sound Effects")
                            .font(Theme.body)
                        Text("Play sounds during focus session transitions and countdown.")
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
                        Text("Haptic feedback during focus sessions.")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $soundManager.vibrationEnabled)
                        .tint(.white)
                }
                
                Divider()
                
                // Daily Motivation toggle per spec
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Daily Motivation")
                            .font(Theme.body)
                        Text("Show inspirational quotes to help you stay motivated.")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $dailyMotivationEnabled)
                        .tint(.white)
                }
            }
        } header: {
            Text("Sound & Haptics").textCase(.none)
        }
    }
    
    // MARK: - Agent 6: Pomodoro Timer Section
    
    private var pomodoroTimerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.formFieldSpacing) {
                // Timer Preset
                Button {
                    showFocusCustomization = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Timer Configuration")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text(focusPreferencesStore.preferences.useCustomIntervals 
                                 ? "Custom: \(Int(focusPreferencesStore.preferences.customFocusDuration / 60)) min focus, \(Int(focusPreferencesStore.preferences.customShortBreakDuration / 60)) min break"
                                 : focusPreferencesStore.preferences.selectedPreset.displayName)
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Divider()
                
                // Auto-start Breaks
                Toggle(isOn: Binding(
                    get: { focusPreferencesStore.preferences.autoStartBreaks },
                    set: { focusPreferencesStore.setAutoStartBreaks($0) }
                )) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Auto-start Breaks")
                            .font(Theme.body)
                        Text("Automatically start break timer after focus session")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(.white)
                
                Divider()
                
                // Auto-start Next Session
                Toggle(isOn: Binding(
                    get: { focusPreferencesStore.preferences.autoStartNextSession },
                    set: { focusPreferencesStore.setAutoStartNextSession($0) }
                )) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Auto-start Next Session")
                            .font(Theme.body)
                        Text("Automatically start next focus session after break")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(.white)
                
                Divider()
                
                // Focus Mode Integration
                Toggle(isOn: Binding(
                    get: { focusPreferencesStore.preferences.enableFocusMode },
                    set: { 
                        focusPreferencesStore.preferences.enableFocusMode = $0
                        focusPreferencesStore.savePreferences()
                    }
                )) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Focus Mode Integration")
                            .font(Theme.body)
                        Text("Suggest iOS Focus Mode activation during sessions")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(.white)
            }
        } header: {
            Text("Pomodoro Timer").textCase(.none)
        } footer: {
            Text("Customize your Pomodoro timer settings and preferences.")
        }
        .sheet(isPresented: $showFocusCustomization) {
            FocusCustomizationView()
                .environmentObject(focusPreferencesStore)
                .iPadOptimizedSheetPresentation()
        }
    }

    private var appearanceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.formFieldSpacing) {
                // Color Theme Selector
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Text("Color Theme")
                            .font(Theme.body)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        // Color preview - refresh when theme changes
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
                        .id(theme.colorTheme) // Force refresh when theme changes
                    }
                    
                    Picker("Color Theme", selection: $theme.colorTheme) {
                        ForEach(Theme.ColorTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Theme.accentA)
                    .id(theme.colorTheme) // Force view refresh when theme changes
                    .onChange(of: theme.colorTheme) { newTheme in
                        // Ensure Theme.currentTheme is updated immediately
                        Theme.currentTheme = newTheme
                        
                        // Save to UserDefaults explicitly
                        UserDefaults.standard.set(newTheme.rawValue, forKey: "colorTheme")
                        UserDefaults.standard.synchronize()
                        
                        // Force UI refresh
                        theme.objectWillChange.send()
                        Haptics.gentle()
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
                
                Divider()
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Match iOS Appearance")
                            .font(Theme.body)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Use your device's Light/Dark setting. Turn off to choose manually.")
                            .font(Theme.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
                    }
                    Spacer()
                    Toggle("", isOn: $matchSystem)
                        .tint(Theme.accentA)
                }

                if !matchSystem {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.formFieldSpacing) {
                        Picker("Appearance", selection: $forcedScheme) {
                            Text("Light").tag(ColorScheme.light)
                            Text("Dark").tag(ColorScheme.dark)
                        }
                        .pickerStyle(.segmented)
                        .tint(Theme.accentA)

                        // Live preview so users instantly "get it".
                        GlassCard(material: .regularMaterial) {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                Image(systemName: forcedScheme == .dark ? "moon.fill" : "sun.max.fill")
                                    .font(Theme.title3)
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                    Text(forcedScheme == .dark ? "Dark Mode Preview" : "Light Mode Preview")
                                        .font(Theme.headline)
                                    Text("Cards, text, and accents adapt to this look.")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                        }
                        .environment(\.colorScheme, forcedScheme)
                        
                        // Color theme preview
                        GlassCard(material: .regularMaterial) {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("Color Theme Preview")
                                        .font(Theme.headline)
                                    Spacer()
                                    HStack(spacing: DesignSystem.Spacing.xs) {
                                        Circle().fill(Theme.accentA).frame(width: DesignSystem.IconSize.small, height: DesignSystem.IconSize.small)
                                        Circle().fill(Theme.accentB).frame(width: DesignSystem.IconSize.small, height: DesignSystem.IconSize.small)
                                        Circle().fill(Theme.accentC).frame(width: DesignSystem.IconSize.small, height: DesignSystem.IconSize.small)
                                    }
                                }
                                
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Theme.accentA)
                                        .frame(height: 20)
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Theme.accentB)
                                        .frame(height: 20)
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(Theme.accentC)
                                        .frame(height: 20)
                                }
                                
                                Text("This is how your app will look with the selected theme.")
                                    .font(Theme.caption)
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Watch connection status
                HStack {
                    Image(systemName: "applewatch")
                        .font(Theme.title2)
                        .foregroundStyle(watchManager.isWatchConnected ? Theme.accentA : .secondary)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("Apple Watch")
                            .font(Theme.body.weight(.semibold))
                        
                        Text(watchStatusText)
                            .font(Theme.caption)
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
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Watch Features:")
                            .font(Theme.caption.weight(.semibold))
                            .foregroundStyle(Theme.accentA)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            HStack {
                                Image(systemName: "mic.fill")
                                    .font(Theme.caption)
                                    .foregroundStyle(Theme.accentB)
                                Text("Voice-to-text focus session notes")
                                    .font(Theme.caption2)
                            }
                            
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(Theme.caption)
                                    .foregroundStyle(Theme.accentB)
                                Text("Quick preset buttons")
                                    .font(Theme.caption2)
                            }
                            
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(Theme.caption)
                                    .foregroundStyle(Theme.accentB)
                                Text("Live streak on watch face")
                                    .font(Theme.caption2)
                            }
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xs)
                }
                
                // Sync button
                if watchManager.isWatchConnected && watchManager.isReachable {
                    Button("Sync with Watch") {
                        watchManager.sendSessionsToWatch()
                        watchManager.updateWatchComplications()
                    }
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textOnDark)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.formFieldSpacing) {
                HStack {
                    Toggle(isOn: $reminderEnabled) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Daily Focus Reminder")
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            Text("Get reminded to complete your daily focus session.")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                                .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
                        }
                    }
                    .tint(Theme.accentA)

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
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.formFieldSpacing) {
                        Toggle(isOn: $streakReminderEnabled) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Streak Reminders")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Get notified if you haven't completed a focus session today and have an active streak.")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
                            }
                        }
                        .tint(Theme.accentA)
                        
                        Toggle(isOn: $noWorkoutNudgeEnabled) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Gentle Nudges")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Receive a gentle reminder if you haven't completed a focus session today.")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
                            }
                        }
                        .tint(Theme.accentA)
                        
                        Toggle(isOn: $weeklySummaryEnabled) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Weekly Progress Summary")
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Get a weekly summary of your focus progress every Sunday.")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(DesignSystem.Typography.captionLineHeight - 1.0)
                            }
                        }
                        .tint(Theme.accentA)
                    }
                }
                
                // Quiet Hours
                Divider()
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Toggle(isOn: $quietHoursEnabled) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Quiet Hours")
                                .font(Theme.body.weight(.semibold))
                            Text("Don't receive notifications during these hours.")
                                .font(Theme.caption)
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
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text(healthKitStatusText)
                            .font(Theme.caption)
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
                    .accessibilityHint("Double tap to connect your focus sessions with Apple Health")
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
                        .font(Theme.caption)
                        .foregroundStyle(Theme.accentA)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        SyncFeatureRow(
                            icon: "figure.run",
                            text: "Focus sessions"
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
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("HealthKit is not available on this device")
                            .font(Theme.caption)
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
                Text("Your focus sessions are automatically synced to Apple Health and Activity apps. Your health data is private and secure.")
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
                    .font(Theme.caption2)
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
            Text("Exports include your focus sessions with timestamps. You can import into other apps or keep a personal backup.")
        }
    }

    private var aboutSection: some View {
        Section {
            // Agent 30: Add help link to settings
            NavigationLink {
                HelpCenterView()
            } label: {
                Label(ButtonLabel.viewHelp.text, systemImage: "questionmark.circle.fill")
            }
            
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
            let data = try enc.encode(focusStore.sessions)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("FocusFlow.json")
            try data.write(to: url, options: .atomic)
            shareItems = [url]
            Haptics.tap()
            showShare = true
        } catch {
            print("Export JSON failed:", error.localizedDescription)
        }
    }

    private func exportCSV() {
        var csv = "date,duration,phaseType,completed,notes\n"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        for e in focusStore.sessions.sorted(by: { $0.date < $1.date }) {
            let ts = formatter.string(from: e.date)
            let escaped = (e.notes ?? "")
                .replacingOccurrences(of: "\"", with: "\"\"")
                .replacingOccurrences(of: "\n", with: " ")
            csv += "\"\(ts)\",\(e.duration),\(e.phaseType.rawValue),\(e.completed),\"\(escaped)\"\n"
        }
        let data = Data(csv.utf8)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("FocusFlow.csv")
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
        // Use NotificationManager for consistent daily reminder scheduling
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        
        // Schedule using NotificationManager which handles daily repeats properly
        NotificationManager.scheduleDailyReminder(at: comps, identifier: "daily_workout")
        
        // Also update the reminder state to reflect it's scheduled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            readCurrentReminderScheduled()
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
        // Use NotificationManager for consistent cancellation
        NotificationManager.cancelDailyReminder(identifier: "daily_workout")
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
            // Check for daily_workout identifier (used by SettingsView) or daily.workout (used by NotificationManager)
            let exists = reqs.contains { $0.identifier == "daily_workout" || $0.identifier == "daily.workout" }
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
