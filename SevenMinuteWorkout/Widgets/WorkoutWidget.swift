import WidgetKit
import SwiftUI

/// Agent 8: iOS Widget for workout tracking
/// Shows current streak, today's workout status, and quick start option
struct WorkoutWidget: Widget {
    let kind: String = "WorkoutWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutTimelineProvider()) { entry in
            WorkoutWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ritual7")
        .description("Track your workout streak and start a quick session.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Timeline Provider

struct WorkoutTimelineProvider: TimelineProvider {
    typealias Entry = WorkoutEntry
    
    func placeholder(in context: Context) -> WorkoutEntry {
        WorkoutEntry(date: Date(), streak: 5, workoutsToday: 1, totalWorkouts: 42)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> Void) {
        let entry = WorkoutEntry(
            date: Date(),
            streak: getStreak(),
            workoutsToday: getWorkoutsToday(),
            totalWorkouts: getTotalWorkouts()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let entry = WorkoutEntry(
            date: currentDate,
            streak: getStreak(),
            workoutsToday: getWorkoutsToday(),
            totalWorkouts: getTotalWorkouts()
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // MARK: - Helper Methods
    
    private func getStreak() -> Int {
        // Read from UserDefaults or shared container
        return UserDefaults(suiteName: "group.com.williamalston.SevenMinuteWorkout")?.integer(forKey: "workoutStreak") ?? 0
    }
    
    private func getWorkoutsToday() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let workouts = UserDefaults(suiteName: "group.com.williamalston.SevenMinuteWorkout")?.array(forKey: "workoutDates") as? [Date] ?? []
        return workouts.filter { Calendar.current.startOfDay(for: $0) == today }.count
    }
    
    private func getTotalWorkouts() -> Int {
        return UserDefaults(suiteName: "group.com.williamalston.SevenMinuteWorkout")?.integer(forKey: "totalWorkouts") ?? 0
    }
}

// MARK: - Timeline Entry

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let workoutsToday: Int
    let totalWorkouts: Int
}

// MARK: - Widget Entry View

struct WorkoutWidgetEntryView: View {
    var entry: WorkoutTimelineProvider.Entry
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
    let entry: WorkoutEntry
    
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
                Image(systemName: "figure.run")
                    .foregroundStyle(.blue)
                Text("\(entry.totalWorkouts)")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
        }
        .padding()
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: WorkoutEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.streak) Day Streak")
                        .font(.headline.weight(.bold))
                }
                
                Text("\(entry.totalWorkouts) Total Workouts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if entry.workoutsToday > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Workout done today!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "figure.run")
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
    let entry: WorkoutEntry
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ritual7")
                        .font(.title2.weight(.bold))
                    
                    Text("Track your progress")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "figure.run")
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
                    icon: "figure.run",
                    value: "\(entry.totalWorkouts)",
                    label: "Total",
                    color: .blue
                )
                
                StatView(
                    icon: "calendar",
                    value: "\(entry.workoutsToday)",
                    label: "Today",
                    color: .green
                )
            }
            
            if entry.workoutsToday == 0 {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.secondary)
                    Text("No workout today yet")
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
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
        )
    }
}

// MARK: - Widget Bundle

struct WorkoutWidgetBundle: WidgetBundle {
    var body: some Widget {
        WorkoutWidget()
    }
}


