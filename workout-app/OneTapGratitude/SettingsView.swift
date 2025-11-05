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

    // Reminders
    @State private var reminderEnabled: Bool = false
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined
    @AppStorage("reminderHour") private var reminderHour: Int = 20
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    
    // Watch connectivity (only used on iPad)
    @StateObject private var watchManager = WatchSessionManager.shared

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
                            Button("Done") { dismiss() }
                                .fontWeight(.semibold)
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sound Effects")
                            .font(.body.weight(.semibold))
                        Text("Play sounds during workout transitions and countdown.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $soundManager.soundEnabled)
                        .tint(.white)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vibration")
                            .font(.body.weight(.semibold))
                        Text("Haptic feedback during workout.")
                            .font(.caption)
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
            VStack(alignment: .leading, spacing: 12) {
                // Color Theme Selector
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Color Theme")
                            .font(.body.weight(.semibold))
                        Spacer()
                        // Color preview
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Theme.accentA)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(Theme.accentB)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(Theme.accentC)
                                .frame(width: 12, height: 12)
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
                .padding(.vertical, 4)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Match iOS Appearance")
                            .font(.body.weight(.semibold))
                        Text("Use your device's Light/Dark setting. Turn off to choose manually.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $matchSystem)
                        .tint(.white)
                }

                if !matchSystem {
                    VStack(alignment: .leading, spacing: 12) {
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
                                Text("Voice-to-text gratitude entry")
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Toggle(isOn: $reminderEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily Reminder")
                                .font(.body.weight(.semibold))
                            Text("A gentle nudge to add one thing you appreciated today.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.white)

                    Spacer(minLength: 8)

                    statusChip
                }

                if reminderEnabled {
                    HStack {
                        Text("Time")
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
                    .padding(.horizontal, 2)
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
            Text("Reminders").textCase(.none)
        } footer: {
            Text(footerCopyForNotifications())
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
            Text("Exports include your entries with timestamps. You can import into other apps or keep a personal backup.")
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
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Theme.strokeOuter, lineWidth: 0.6))
            case .denied:
                Label("Off", systemImage: "bell.slash.fill")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Theme.strokeOuter, lineWidth: 0.6))
            default:
                Label("Ask", systemImage: "questionmark.diamond.fill")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Theme.strokeOuter, lineWidth: 0.6))
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
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("OneTapGratitude.json")
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
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("OneTapGratitude.csv")
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
