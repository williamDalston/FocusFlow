import WidgetKit
import SwiftUI

/// Agent 24: iOS Widget for focus session tracking
/// Shows current streak, today's focus sessions, and quick start option
struct FocusWidget: Widget {
    let kind: String = "FocusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                FocusWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FocusWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color(.systemBackground))
            }
        }
        .configurationDisplayName("FocusFlow")
        .description("Track your focus streak and start a quick session.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Timeline Provider

struct FocusTimelineProvider: TimelineProvider {
    typealias Entry = FocusEntry
    
    func placeholder(in context: Context) -> FocusEntry {
        FocusEntry(date: Date(), streak: 5, focusSessionsToday: 1, totalFocusSessions: 42)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FocusEntry) -> Void) {
        let entry = FocusEntry(
            date: Date(),
            streak: getStreak(),
            focusSessionsToday: getFocusSessionsToday(),
            totalFocusSessions: getTotalFocusSessions()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let entry = FocusEntry(
            date: currentDate,
            streak: getStreak(),
            focusSessionsToday: getFocusSessionsToday(),
            totalFocusSessions: getTotalFocusSessions()
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - Helper Methods
    
    private func getStreak() -> Int {
        // Read from UserDefaults or shared container
        // Try app group first, then standard UserDefaults
        if let appGroup = UserDefaults(suiteName: "group.com.williamalston.workout") {
            return appGroup.integer(forKey: AppConstants.UserDefaultsKeys.focusStreak)
        }
        return UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.focusStreak)
    }
    
    private func getFocusSessionsToday() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Try to read from app group first
        if let appGroup = UserDefaults(suiteName: "group.com.williamalston.workout"),
           let sessionsData = appGroup.data(forKey: AppConstants.UserDefaultsKeys.focusSessions) {
            do {
                let sessions = try JSONDecoder().decode([FocusSession].self, from: sessionsData)
                return sessions.filter { Calendar.current.startOfDay(for: $0.date) == today }.count
            } catch {
                // If decoding fails, try to read count from UserDefaults directly
                return 0
            }
        }
        
        // Fall back to standard UserDefaults
        if let sessionsData = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.focusSessions) {
            do {
                let sessions = try JSONDecoder().decode([FocusSession].self, from: sessionsData)
                return sessions.filter { Calendar.current.startOfDay(for: $0.date) == today }.count
            } catch {
                return 0
            }
        }
        
        return 0
    }
    
    private func getTotalFocusSessions() -> Int {
        // Try app group first, then standard UserDefaults
        if let appGroup = UserDefaults(suiteName: "group.com.williamalston.workout") {
            return appGroup.integer(forKey: AppConstants.UserDefaultsKeys.focusTotalSessions)
        }
        return UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKeys.focusTotalSessions)
    }
}

// MARK: - Timeline Entry

struct FocusEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let focusSessionsToday: Int
    let totalFocusSessions: Int
}

// MARK: - Widget Entry View

struct FocusWidgetEntryView: View {
    var entry: FocusTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: FocusEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(entry.streak)")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            Text("Day Streak")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.blue)
                Text("\(entry.totalFocusSessions)")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
        }
        .padding()
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: FocusEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.streak) Day Streak")
                        .font(.headline.weight(.bold))
                }
                
                Text("\(entry.totalFocusSessions) Total Sessions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if entry.focusSessionsToday > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Focus session done today!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                Text("Start")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let entry: FocusEntry
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("FocusFlow")
                        .font(.title2.weight(.bold))
                    
                    Text("Track your progress")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
            }
            
            HStack(spacing: 20) {
                StatView(
                    icon: "flame.fill",
                    value: "\(entry.streak)",
                    label: "Day Streak",
                    color: .orange
                )
                
                StatView(
                    icon: "brain.head.profile",
                    value: "\(entry.totalFocusSessions)",
                    label: "Total",
                    color: .blue
                )
                
                StatView(
                    icon: "calendar",
                    value: "\(entry.focusSessionsToday)",
                    label: "Today",
                    color: .green
                )
            }
            
            if entry.focusSessionsToday == 0 {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.secondary)
                    Text("No focus session today yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

// MARK: - Stat View

struct StatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)
            
            Text(value)
                .font(.title.weight(.bold))
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(.quaternary)
        )
    }
}

// MARK: - Widget Bundle

struct FocusWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusWidget()
    }
}

// Note: FocusSession model is imported from FocusFlow/Models/FocusSession.swift

