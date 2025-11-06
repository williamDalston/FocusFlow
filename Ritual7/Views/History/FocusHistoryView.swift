import SwiftUI

/// Agent 11: Focus History View - Displays completed Pomodoro focus sessions
/// This is a minimal placeholder that will be enhanced by Agent 13
/// TODO: Agent 13 - Create comprehensive FocusHistoryView with filtering, search, export, and visualizations
struct FocusHistoryView: View {
    @EnvironmentObject private var store: FocusStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var selectedDateRange: DateRange = .all
    
    private var filteredSessions: [FocusSession] {
        var sessions = store.sessions
        
        // Apply date range filter
        switch selectedDateRange {
        case .all:
            break
        case .today:
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            sessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: today) }
        case .thisWeek:
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            sessions = sessions.filter { $0.date >= weekAgo }
        case .thisMonth:
            let calendar = Calendar.current
            let now = Date()
            sessions = sessions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .last30Days:
            let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
            sessions = sessions.filter { $0.date >= thirtyDaysAgo }
        case .custom:
            // TODO: Agent 13 - Implement custom date range
            break
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            sessions = sessions.filter { session in
                let dateString = session.date.formatted(date: .abbreviated, time: .shortened)
                let notesString = session.notes ?? ""
                return dateString.localizedCaseInsensitiveContains(searchText) ||
                       notesString.localizedCaseInsensitiveContains(searchText) ||
                       session.phaseType.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return sessions.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Search bar - TODO: Agent 13 - Enhance with advanced filtering
                if !filteredSessions.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Theme.textSecondary)
                        TextField("Search sessions...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                // Date range filter - TODO: Agent 13 - Enhance with better UI
                if !filteredSessions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach([DateRange.all, .today, .thisWeek, .thisMonth, .last30Days], id: \.self) { range in
                                Button(action: {
                                    selectedDateRange = range
                                }) {
                                    Text(range.displayName)
                                        .font(Theme.caption)
                                        .foregroundStyle(selectedDateRange == range ? .white : Theme.textPrimary)
                                        .padding(.horizontal, DesignSystem.Spacing.md)
                                        .padding(.vertical, DesignSystem.Spacing.sm)
                                        .background(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                                .fill(selectedDateRange == range ? Theme.accent : .ultraThinMaterial)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                }
                
                // Sessions list - TODO: Agent 13 - Create FocusHistoryRow with beautiful design
                if filteredSessions.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.textSecondary)
                        Text("No focus sessions yet")
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Start your first Pomodoro session to see it here")
                            .font(Theme.body)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(DesignSystem.Spacing.xl)
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(filteredSessions) { session in
                            FocusHistoryRow(session: session)
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

/// Agent 11: Focus History Row - Displays a single focus session
/// TODO: Agent 13 - Enhance with beautiful design, phase icons, and cycle information
struct FocusHistoryRow: View {
    let session: FocusSession
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Phase icon
            Image(systemName: phaseIcon)
                .font(Theme.title3)
                .foregroundStyle(phaseColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(phaseColor.opacity(0.2))
                )
            
            // Session info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(session.phaseType.displayName)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            
            Spacer()
            
            // Duration
            Text(formatDuration(session.duration))
                .font(Theme.body)
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var phaseIcon: String {
        switch session.phaseType {
        case .focus:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "moon.zzz"
        }
    }
    
    private var phaseColor: Color {
        switch session.phaseType {
        case .focus:
            return Theme.accent
        case .shortBreak:
            return Theme.accentB
        case .longBreak:
            return Theme.accentC
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

/// Date range filter options
enum DateRange: String, CaseIterable {
    case all = "all"
    case today = "today"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    case last30Days = "last30Days"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .last30Days: return "Last 30 Days"
        case .custom: return "Custom"
        }
    }
}

#if DEBUG
struct FocusHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        FocusHistoryView()
            .environmentObject(FocusStore())
    }
}
#endif

