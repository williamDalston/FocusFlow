import SwiftUI
import Charts

/// Agent 1: Missing Views - Comprehensive workout history view with filtering, search, export, and share
/// Agent 20: Enhanced with timeline view, workout patterns, grouped sections, and best week highlight
struct WorkoutHistoryView: View {
    @EnvironmentObject private var store: WorkoutStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedDateRange: DateRange = .all
    @State private var customStartDate: Date = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
    @State private var customEndDate: Date = Date()
    @State private var showingExportSheet = false
    @State private var selectedSession: WorkoutSession?
    @State private var isLoading = false  // Agent 16: Loading state for skeleton loaders
    @State private var viewMode: ViewMode = .list  // Agent 20: Timeline view toggle
    @State private var showingPatterns = false  // Agent 20: Workout patterns visualization
    
    // Agent 25: Confirmation dialogs
    @State private var showingDeleteConfirmation = false
    @State private var sessionToDelete: WorkoutSession?
    @State private var showingDeleteAllConfirmation = false
    
    // Agent 20: View mode enum
    enum ViewMode {
        case list
        case timeline
        
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .timeline: return "timeline.selection"
            }
        }
    }
    
    private var filteredSessions: [WorkoutSession] {
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
            sessions = sessions.filter { $0.date >= customStartDate && $0.date <= customEndDate }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            sessions = sessions.filter { session in
                let dateString = session.date.formatted(date: .abbreviated, time: .shortened)
                let notesString = session.notes ?? ""
                return dateString.localizedCaseInsensitiveContains(searchText) ||
                       notesString.localizedCaseInsensitiveContains(searchText) ||
                       "\(session.exercisesCompleted)".contains(searchText) ||
                       formatDuration(session.duration).contains(searchText)
            }
        }
        
        return sessions.sorted { $0.date > $1.date }
    }
    
    // Agent 20: Grouped sessions by date sections
    private var groupedSessions: [WorkoutDateSection] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        
        var sections: [WorkoutDateSection] = []
        var todaySessions: [WorkoutSession] = []
        var yesterdaySessions: [WorkoutSession] = []
        var thisWeekSessions: [WorkoutSession] = []
        var thisMonthSessions: [WorkoutSession] = []
        var olderSessions: [WorkoutSession] = []
        
        for session in filteredSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if calendar.isDate(sessionDate, inSameDayAs: today) {
                todaySessions.append(session)
            } else if calendar.isDate(sessionDate, inSameDayAs: yesterday) {
                yesterdaySessions.append(session)
            } else if session.date >= weekAgo {
                thisWeekSessions.append(session)
            } else if session.date >= monthAgo {
                thisMonthSessions.append(session)
            } else {
                olderSessions.append(session)
            }
        }
        
        if !todaySessions.isEmpty {
            sections.append(WorkoutDateSection(title: "Today", sessions: todaySessions))
        }
        if !yesterdaySessions.isEmpty {
            sections.append(WorkoutDateSection(title: "Yesterday", sessions: yesterdaySessions))
        }
        if !thisWeekSessions.isEmpty {
            sections.append(WorkoutDateSection(title: "This Week", sessions: thisWeekSessions))
        }
        if !thisMonthSessions.isEmpty {
            sections.append(WorkoutDateSection(title: "This Month", sessions: thisMonthSessions))
        }
        if !olderSessions.isEmpty {
            sections.append(WorkoutDateSection(title: "Older", sessions: olderSessions))
        }
        
        return sections
    }
    
    // Agent 20: Best week calculation
    private var bestWeek: BestWeek? {
        let calendar = Calendar.current
        var weekCounts: [Date: Int] = [:]
        
        for session in store.sessions {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: session.date)?.start ?? session.date
            weekCounts[weekStart, default: 0] += 1
        }
        
        guard let bestWeekStart = weekCounts.max(by: { $0.value < $1.value })?.key,
              let bestWeekCount = weekCounts[bestWeekStart] else {
            return nil
        }
        
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: bestWeekStart) ?? bestWeekStart
        return BestWeek(startDate: bestWeekStart, endDate: weekEnd, workoutCount: bestWeekCount)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            searchAndFilterBar
            
            // Content
            // Agent 16: Show skeleton loaders while loading
            if isLoading {
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Summary skeleton
                        SkeletonCard(height: 100)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.top, DesignSystem.Spacing.lg)
                        
                        // List skeleton
                        SkeletonList(count: 5)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                }
                .loadingTransition(isLoading)
            } else if filteredSessions.isEmpty {
                emptyStateView
            } else {
                workoutList
            }
        }
        .navigationTitle("Workout History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if horizontalSizeClass == .regular {
                    EmptyView()
                } else {
                    Button("Done") {
                        dismiss()
                        Haptics.tap()
                    }
                    .font(Theme.headline)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Agent 20: View mode toggle
                    Button {
                        viewMode = viewMode == .list ? .timeline : .list
                        Haptics.tap()
                    } label: {
                        Image(systemName: viewMode.icon)
                            .font(Theme.headline)
                            .foregroundStyle(Theme.accentA)
                    }
                    .accessibilityLabel(viewMode == .list ? "Switch to Timeline View" : "Switch to List View")
                    
                    Menu {
                        // Agent 20: Workout patterns option
                        Button {
                            showingPatterns = true
                            Haptics.tap()
                        } label: {
                            Label("Workout Patterns", systemImage: "chart.bar.fill")
                        }
                        
                        Divider()
                        
                        Button {
                            showingFilter = true
                            Haptics.tap()
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        
                        Button {
                            showingExportSheet = true
                            Haptics.tap()
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            shareAllWorkouts()
                            Haptics.tap()
                        } label: {
                            Label("Share Summary", systemImage: "square.and.arrow.up.on.square")
                        }
                        
                        if !filteredSessions.isEmpty {
                            Divider()
                            
                            Button(role: .destructive) {
                                // Agent 25: Show confirmation before deleting all
                                showingDeleteAllConfirmation = true
                                Haptics.tap()
                            } label: {
                                Label("Delete All", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(Theme.headline)
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilter) {
            WorkoutHistoryFilterView(
                selectedDateRange: $selectedDateRange,
                customStartDate: $customStartDate,
                customEndDate: $customEndDate
            )
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportOptionsView(sessions: filteredSessions)
        }
        .sheet(isPresented: $showingPatterns) {
            WorkoutPatternsView(sessions: store.sessions)
        }
        .sheet(item: $selectedSession) { session in
            WorkoutSessionDetailView(session: session)
        }
        // Agent 25: Confirmation dialogs
        .confirmationDialog("Delete Workout", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    deleteSession(session)
                    sessionToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action can be undone.")
        }
        .confirmationDialog("Delete All Workouts", isPresented: $showingDeleteAllConfirmation, titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                deleteAllFiltered()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete all \(filteredSessions.count) filtered workout\(filteredSessions.count == 1 ? "" : "s")? This action can be undone.")
        }
        .undoToast() // Agent 25: Enable undo toast notifications
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Search bar
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search workouts...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        Haptics.tap()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                    )
            )
            
            // Filter chips
            if selectedDateRange != .all || !searchText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        if selectedDateRange != .all {
                            FilterChip(
                                title: selectedDateRange.displayName,
                                isActive: true,
                                action: {
                                    showingFilter = true
                                    Haptics.tap()
                                }
                            )
                        }
                        
                        if !searchText.isEmpty {
                            FilterChip(
                                title: "Search: \"\(searchText)\"",
                                isActive: true,
                                action: {
                                    searchText = ""
                                    Haptics.tap()
                                }
                            )
                        }
                        
                        Button {
                            selectedDateRange = .all
                            searchText = ""
                            Haptics.tap()
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(Theme.caption)
                                Text("Clear All")
                                    .font(Theme.caption)
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        Group {
            if store.sessions.isEmpty {
                EmptyStateView.noWorkouts {
                    // This will be handled by the parent view
                }
            } else {
                EmptyStateView.noHistoryFound {
                    selectedDateRange = .all
                    searchText = ""
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Workout List
    
    private var workoutList: some View {
        Group {
            if viewMode == .list {
                listView
            } else {
                timelineView
            }
        }
    }
    
    private var listView: some View {
        List {
            // Agent 20: Best week highlight
            if let bestWeek = bestWeek {
                Section {
                    BestWeekCard(bestWeek: bestWeek)
                }
            }
            
            // Summary section
            if !filteredSessions.isEmpty {
                Section {
                    WorkoutHistorySummaryView(sessions: filteredSessions)
                }
            }
            
            // Agent 20: Grouped sessions by date
            if !groupedSessions.isEmpty {
                ForEach(groupedSessions) { section in
                    Section {
                        ForEach(Array(section.sessions.enumerated()), id: \.element.id) { index, session in
                            WorkoutHistoryRow(session: session)
                                .contentShape(Rectangle())
                                .staggeredEntrance(index: index, delay: 0.04)
                                .cardLift()
                                .onTapGesture {
                                    selectedSession = session
                                    Haptics.buttonPress()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        // Agent 25: Show confirmation before deleting
                                        sessionToDelete = session
                                        showingDeleteConfirmation = true
                                        Haptics.buttonPress()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        shareSession(session)
                                        Haptics.buttonPress()
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(Theme.accentA)
                                }
                        }
                        .onDelete { indexSet in
                            // Filter out invalid indices to prevent crashes
                            let validIndices = indexSet.filter { $0 >= 0 && $0 < section.sessions.count }
                            let sessionsToDelete = validIndices.compactMap { index -> WorkoutSession? in
                                guard index >= 0 && index < section.sessions.count else { return nil }
                                return section.sessions[index]
                            }
                            // Agent 25: Show confirmation for bulk delete
                            if sessionsToDelete.count > 1 {
                                showingDeleteAllConfirmation = true
                            } else {
                                for session in sessionsToDelete {
                                    deleteSession(session)
                                }
                            }
                            Haptics.buttonPress()
                        }
                    } header: {
                        // Agent 23: Enhanced section header hierarchy
                        Text(section.title)
                            .font(.system(size: DesignSystem.Hierarchy.tertiaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                            .allowsTightening(false) // Prevent hyphen splits
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable {
            // Agent 16: Show loading state during refresh
            isLoading = true
            // Pull-to-refresh: reload workout data
            await refreshWorkoutData()
            isLoading = false
        }
    }
    
    // Agent 20: Timeline view
    private var timelineView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Agent 20: Best week highlight
                if let bestWeek = bestWeek {
                    BestWeekCard(bestWeek: bestWeek)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.lg)
                }
                
                // Summary section
                if !filteredSessions.isEmpty {
                    WorkoutHistorySummaryView(sessions: filteredSessions)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                // Timeline view
                VStack(spacing: DesignSystem.Spacing.xl) {
                    ForEach(groupedSessions) { section in
                        TimelineSectionView(section: section, onSessionTap: { session in
                            selectedSession = session
                            Haptics.buttonPress()
                        }, onDelete: { session in
                            deleteSession(session)
                            Haptics.buttonPress()
                        }, onShare: { session in
                            shareSession(session)
                            Haptics.buttonPress()
                        })
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .refreshable {
            isLoading = true
            await refreshWorkoutData()
            isLoading = false
        }
    }
    
    @MainActor
    private func refreshWorkoutData() async {
        // Trigger haptic feedback
        Haptics.buttonPress()
        
        // Agent 16: Simulate data loading for smooth transition
        // Reload workout store data
        // The WorkoutStore will automatically refresh when accessed
        // Small delay for visual feedback and smooth skeleton transition
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay for smooth transition
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Agent 26: Optimistic update state for undo support (using WorkoutStore's built-in undo)
    
    private func deleteSession(_ session: WorkoutSession) {
        // Agent 25: Delete with undo support
        if let index = store.sessions.firstIndex(where: { $0.id == session.id }) {
            store.deleteSession(at: IndexSet(integer: index))
            
            // Agent 25: Show toast with undo option
            ToastManager.shared.show(
                message: "Workout deleted",
                onUndo: {
                    store.undoDelete()
                    Haptics.success()
                }
            )
        }
        
        // Haptic feedback
        Haptics.buttonPress()
    }
    
    private func deleteAllFiltered() {
        // Agent 26: Optimistic update for batch delete
        let sessionsToDelete = filteredSessions
        let indices = sessionsToDelete.compactMap { session in
            store.sessions.firstIndex(where: { $0.id == session.id })
        }
        
        if !indices.isEmpty {
            store.deleteSession(at: IndexSet(indices))
            
            // Show undo toast
            ToastManager.shared.show(
                message: "\(sessionsToDelete.count) workout\(sessionsToDelete.count == 1 ? "" : "s") deleted",
                onUndo: {
                    store.undoDelete()
                    Haptics.success()
                }
            )
        }
        
        Haptics.buttonPress()
    }
    
    private func shareSession(_ session: WorkoutSession) {
        WorkoutShareManager.shared.shareWorkoutCompletion(
            session: session,
            streak: store.streak,
            from: UIApplication.shared.firstKeyWindow?.rootViewController
        )
    }
    
    private func shareAllWorkouts() {
        let totalWorkouts = filteredSessions.count
        let totalMinutes = filteredSessions.reduce(0.0) { $0 + $1.duration } / 60.0
        
        WorkoutShareManager.shared.shareWorkoutSummary(
            totalWorkouts: totalWorkouts,
            streak: store.streak,
            totalMinutes: totalMinutes,
            estimatedCalories: totalWorkouts * 100,
            from: UIApplication.shared.firstKeyWindow?.rootViewController
        )
    }
}

// MARK: - Date Range Enum

enum DateRange: String, CaseIterable {
    case all = "all"
    case today = "today"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    case last30Days = "last30Days"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .last30Days: return "Last 30 Days"
        case .custom: return "Custom Range"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "calendar"
        case .today: return "sun.max.fill"
        case .thisWeek: return "calendar.badge.clock"
        case .thisMonth: return "calendar"
        case .last30Days: return "calendar.badge.clock"
        case .custom: return "calendar.badge.plus"
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(Theme.caption)
                if isActive {
                    Image(systemName: "xmark.circle.fill")
                        .font(Theme.caption2)
                }
            }
            .foregroundStyle(isActive ? Theme.textPrimary : .secondary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                Capsule()
                    .fill(isActive ? AnyShapeStyle(Theme.accentA.opacity(DesignSystem.Opacity.subtle)) : AnyShapeStyle(Material.ultraThinMaterial))
                    .overlay(
                        Capsule()
                            .stroke(isActive ? Theme.accentA.opacity(DesignSystem.Opacity.light) : Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                    )
            )
        }
    }
}

// MARK: - Workout History Summary View

struct WorkoutHistorySummaryView: View {
    let sessions: [WorkoutSession]
    
    private var totalWorkouts: Int { sessions.count }
    private var totalMinutes: TimeInterval {
        sessions.reduce(0.0) { $0 + $1.duration } / 60.0
    }
    private var averageDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0.0) { $0 + $1.duration } / Double(sessions.count)
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.md) {
            SummaryCard(
                title: "Total",
                value: "\(totalWorkouts)",
                icon: "figure.run",
                color: Theme.accentA
            )
            
            SummaryCard(
                title: "Total Time",
                value: "\(Int(totalMinutes))m",
                icon: "clock.fill",
                color: Theme.accentB
            )
            
            SummaryCard(
                title: "Avg Duration",
                value: formatDuration(averageDuration),
                icon: "timer",
                color: Theme.accentC
            )
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(Theme.title3)
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .stroke(color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.subtle)
                )
        )
    }
}

// MARK: - Workout Session Detail View

struct WorkoutSessionDetailView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: WorkoutStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Header
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                                .foregroundStyle(.green)
                            
                            Text("Workout Complete")
                                .font(Theme.largeTitle)
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text(session.date.formatted(date: .long, time: .shortened))
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, DesignSystem.Spacing.xxl)
                        
                        // Stats
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            DetailStatRow(
                                icon: "figure.run",
                                title: "Exercises Completed",
                                value: "\(session.exercisesCompleted)",
                                color: Theme.accentA
                            )
                            
                            DetailStatRow(
                                icon: "clock.fill",
                                title: "Duration",
                                value: formatDuration(session.duration),
                                color: Theme.accentB
                            )
                            
                            if let notes = session.notes, !notes.isEmpty {
                                GlassCard(material: .ultraThinMaterial) {
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                        Text("Notes")
                                            .font(Theme.headline)
                                            .foregroundStyle(Theme.textPrimary)
                                        
                                        Text(notes)
                                            .font(Theme.body)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cardPadding()
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Actions
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Button {
                                shareSession()
                                Haptics.tap()
                            } label: {
                                Label("Share Workout", systemImage: "square.and.arrow.up")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                            .buttonStyle(PrimaryProminentButtonStyle())
                            
                            Button(role: .destructive) {
                                deleteSession()
                                dismiss()
                                Haptics.tap()
                            } label: {
                                Label("Delete Workout", systemImage: "trash")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            .buttonStyle(SecondaryGlassButtonStyle())
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                }
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Show interstitial ad after viewing workout details (natural break point)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            InterstitialAdManager.shared.present(from: nil)
                        }
                        dismiss()
                        Haptics.tap()
                    }
                    .font(Theme.headline)
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func shareSession() {
        WorkoutShareManager.shared.shareWorkoutCompletion(
            session: session,
            streak: store.streak,
            from: UIApplication.shared.firstKeyWindow?.rootViewController
        )
    }
    
    private func deleteSession() {
        if let index = store.sessions.firstIndex(where: { $0.id == session.id }) {
            store.deleteSession(at: IndexSet(integer: index))
        }
    }
}

// MARK: - Detail Stat Row

struct DetailStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(Theme.title2)
                .foregroundStyle(color)
                .frame(width: DesignSystem.IconSize.xlarge, height: DesignSystem.IconSize.xlarge)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(Theme.title2)
                    .foregroundStyle(Theme.textPrimary)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .stroke(color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.subtle)
                )
        )
    }
}

// MARK: - Export Options View

struct ExportOptionsView: View {
    let sessions: [WorkoutSession]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    Text("Export \(sessions.count) Workout\(sessions.count == 1 ? "" : "s")")
                        .font(Theme.title2)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.top, DesignSystem.Spacing.xxl)
                    
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ExportButton(sessions: sessions, format: .json)
                        ExportButton(sessions: sessions, format: .csv)
                        ExportButton(sessions: sessions, format: .pdf)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer()
                }
            }
            .navigationTitle("Export Workouts")
            .navigationBarTitleDisplayMode(.inline)
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
}

// MARK: - Export Button

struct ExportButton: View {
    let sessions: [WorkoutSession]
    let format: ExportFormat
    
    enum ExportFormat {
        case json, csv, pdf
        
        var displayName: String {
            switch self {
            case .json: return "JSON"
            case .csv: return "CSV"
            case .pdf: return "PDF"
            }
        }
        
        var icon: String {
            switch self {
            case .json: return "doc.text"
            case .csv: return "doc.text.fill"
            case .pdf: return "doc.fill"
            }
        }
    }
    
    var body: some View {
        Button {
            export()
            Haptics.tap()
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: format.icon)
                    .font(Theme.title3)
                    .foregroundStyle(Theme.accentA)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Export as \(format.displayName)")
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("\(sessions.count) workout\(sessions.count == 1 ? "" : "s")")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(Theme.accentA.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.subtle)
                    )
            )
        }
    }
    
    private func export() {
        let data: Data?
        let filename: String
        
        switch format {
        case .json:
            data = try? JSONEncoder().encode(sessions)
            filename = "workouts_\(Date().formatted(date: .numeric, time: .omitted)).json"
        case .csv:
            data = generateCSV()
            filename = "workouts_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        case .pdf:
            data = nil // PDF export would require additional implementation
            filename = ""
        }
        
        guard let data = data else {
            // Show error or implement PDF export
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: tempURL)
        
        let activityViewController = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )
        
        if let window = UIApplication.shared.firstKeyWindow,
           let rootViewController = window.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = window
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    private func generateCSV() -> Data? {
        var csv = "Date,Exercises Completed,Duration (seconds),Notes\n"
        
        for session in sessions {
            let dateString = session.date.formatted(date: .abbreviated, time: .shortened)
            let duration = Int(session.duration)
            let notes = session.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            csv += "\(dateString),\(session.exercisesCompleted),\(duration),\(notes)\n"
        }
        
        return csv.data(using: .utf8)
    }
}

// MARK: - Agent 20: Supporting Types

/// Date section for grouping workouts
struct WorkoutDateSection: Identifiable {
    let id = UUID()
    let title: String
    let sessions: [WorkoutSession]
}

/// Best week information
struct BestWeek {
    let startDate: Date
    let endDate: Date
    let workoutCount: Int
}

// MARK: - Agent 20: Best Week Card

struct BestWeekCard: View {
    let bestWeek: BestWeek
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.accentA.opacity(0.3),
                                Theme.accentB.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.accentA)
            }
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Your Best Week")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Text("\(bestWeek.workoutCount) workout\(bestWeek.workoutCount == 1 ? "" : "s")")
                    .font(Theme.title3)
                    .foregroundStyle(Theme.accentA)
                    .monospacedDigit()
                
                Text(formatDateRange(bestWeek.startDate, bestWeek.endDate))
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.5),
                            Theme.accentB.opacity(DesignSystem.Opacity.subtle * 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(DesignSystem.Opacity.light),
                                    Theme.accentB.opacity(DesignSystem.Opacity.light * 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.standard
                        )
                )
        )
        .cardShadow()
    }
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        return "\(startString) - \(endString)"
    }
}

// MARK: - Agent 20: Timeline Section View

struct TimelineSectionView: View {
    let section: WorkoutDateSection
    let onSessionTap: (WorkoutSession) -> Void
    let onDelete: (WorkoutSession) -> Void
    let onShare: (WorkoutSession) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Agent 23: Enhanced section header hierarchy
            HStack {
                Text(section.title)
                    .font(.system(size: DesignSystem.Hierarchy.tertiaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Text("\(section.sessions.count)")
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary.opacity(DesignSystem.Hierarchy.tertiaryOpacity))
                    .monospacedDigit()
            }
            
            // Timeline items
            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(Array(section.sessions.enumerated()), id: \.element.id) { index, session in
                    TimelineItemView(
                        session: session,
                        isFirst: index == 0,
                        isLast: index == section.sessions.count - 1,
                        onTap: { onSessionTap(session) },
                        onDelete: { onDelete(session) },
                        onShare: { onShare(session) }
                    )
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
    }
}

// MARK: - Agent 20: Timeline Item View

struct TimelineItemView: View {
    let session: WorkoutSession
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(Theme.accentA)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Theme.accentA.opacity(0.3), lineWidth: 4)
                            .frame(width: 20, height: 20)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Theme.accentA.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer()
                }
            }
            .frame(width: 20)
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(formatTime(session.date))
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(formatDuration(session.duration))
                        .font(Theme.subheadline)
                        .foregroundStyle(Theme.accentA)
                        .monospacedDigit()
                }
                
                Text("\(session.exercisesCompleted) exercises completed")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textPrimary)
                
                if let notes = session.notes, !notes.isEmpty {
                    Text(notes)
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
            Haptics.buttonPress()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
                Haptics.buttonPress()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onShare()
                Haptics.buttonPress()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .tint(Theme.accentA)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Agent 20: Workout Patterns View

struct WorkoutPatternsView: View {
    let sessions: [WorkoutSession]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: PatternType = .timeOfDay
    
    enum PatternType {
        case timeOfDay
        case dayOfWeek
        
        var title: String {
            switch self {
            case .timeOfDay: return "Time of Day"
            case .dayOfWeek: return "Day of Week"
            }
        }
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Picker
                        Picker("Pattern Type", selection: $selectedType) {
                            Text("Time of Day").tag(PatternType.timeOfDay)
                            Text("Day of Week").tag(PatternType.dayOfWeek)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.lg)
                        
                        // Chart
                        if selectedType == .timeOfDay {
                            timeOfDayChart
                        } else {
                            dayOfWeekChart
                        }
                        
                        // Insights
                        insightsCard
                    }
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .navigationTitle("Workout Patterns")
            .navigationBarTitleDisplayMode(.inline)
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
    
    private var timeOfDayChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Agent 23: Enhanced section title hierarchy
            Text("Workout Time Distribution")
                .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            let frequency = calculateTimeOfDayFrequency()
            Chart(TimeOfDay.allCases.filter { $0 != .unknown }) { time in
                BarMark(
                    x: .value("Time", time.displayName),
                    y: .value("Workouts", frequency[time] ?? 0)
                )
                .foregroundStyle(Theme.accentA.gradient)
                .cornerRadius(DesignSystem.CornerRadius.small)
            }
            .frame(height: 250)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var dayOfWeekChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Agent 23: Enhanced section title hierarchy
            Text("Workout Day Distribution")
                .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            let frequency = calculateDayOfWeekFrequency()
            Chart(DayOfWeek.allCases) { day in
                BarMark(
                    x: .value("Day", day.shortName),
                    y: .value("Workouts", frequency[day] ?? 0)
                )
                .foregroundStyle(Theme.accentB.gradient)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous))
            }
            .frame(height: 250)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Agent 23: Enhanced section title hierarchy
            Text("Insights")
                .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            
            let bestTime = calculateBestTime()
            let bestDay = calculateBestDay()
            
            if let bestTime = bestTime {
                InsightRow(
                    icon: "sun.max.fill",
                    title: "Most Active Time",
                    value: bestTime.displayName,
                    color: Theme.accentA
                )
            }
            
            if let bestDay = bestDay {
                InsightRow(
                    icon: "calendar",
                    title: "Most Consistent Day",
                    value: bestDay.displayName,
                    color: Theme.accentB
                )
            }
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private func calculateTimeOfDayFrequency() -> [TimeOfDay: Int] {
        let calendar = Calendar.current
        var frequency: [TimeOfDay: Int] = [:]
        
        for session in sessions {
            let hour = calendar.component(.hour, from: session.date)
            let timeOfDay: TimeOfDay
            
            switch hour {
            case 5..<12: timeOfDay = .morning
            case 12..<17: timeOfDay = .afternoon
            case 17..<22: timeOfDay = .evening
            default: timeOfDay = .night
            }
            
            frequency[timeOfDay, default: 0] += 1
        }
        
        return frequency
    }
    
    private func calculateDayOfWeekFrequency() -> [DayOfWeek: Int] {
        let calendar = Calendar.current
        var frequency: [DayOfWeek: Int] = [:]
        
        for session in sessions {
            let weekday = calendar.component(.weekday, from: session.date)
            if let day = DayOfWeek(rawValue: weekday) {
                frequency[day, default: 0] += 1
            }
        }
        
        return frequency
    }
    
    private func calculateBestTime() -> TimeOfDay? {
        let frequency = calculateTimeOfDayFrequency()
        return frequency.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateBestDay() -> DayOfWeek? {
        let frequency = calculateDayOfWeekFrequency()
        return frequency.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Agent 20: Insight Row

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(color)
                .frame(width: DesignSystem.IconSize.medium, height: DesignSystem.IconSize.medium)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textPrimary)
            }
            
            Spacer()
        }
    }
}

