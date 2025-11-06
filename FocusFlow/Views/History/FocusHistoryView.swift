import SwiftUI
import Charts

/// Agent 13: Focus History View - Comprehensive focus history view with filtering, search, export, and share
/// Refactored from WorkoutHistoryView for Pomodoro Timer app
struct FocusHistoryView: View {
    @EnvironmentObject private var store: FocusStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var showingFilter = false
    @State private var selectedDateRange: DateRange = .all
    @State private var customStartDate: Date = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
    @State private var customEndDate: Date = Date()
    @State private var showingExportSheet = false
    @State private var selectedSession: FocusSession?
    @State private var isLoading = false
    @State private var viewMode: ViewMode = .list
    @State private var showingPatterns = false
    
    // Confirmation dialogs
    @State private var showingDeleteConfirmation = false
    @State private var sessionToDelete: FocusSession?
    @State private var showingDeleteAllConfirmation = false
    
    // View mode enum
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
            sessions = sessions.filter { $0.date >= customStartDate && $0.date <= customEndDate }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            sessions = sessions.filter { session in
                let dateString = session.date.formatted(date: .abbreviated, time: .shortened)
                let notesString = session.notes ?? ""
                let phaseTypeString = session.phaseType.displayName
                return dateString.localizedCaseInsensitiveContains(searchText) ||
                       notesString.localizedCaseInsensitiveContains(searchText) ||
                       phaseTypeString.localizedCaseInsensitiveContains(searchText) ||
                       formatDuration(session.duration).contains(searchText)
            }
        }
        
        return sessions.sorted { $0.date > $1.date }
    }
    
    // Grouped sessions by date sections
    private var groupedSessions: [FocusDateSection] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        
        var sections: [FocusDateSection] = []
        var todaySessions: [FocusSession] = []
        var yesterdaySessions: [FocusSession] = []
        var thisWeekSessions: [FocusSession] = []
        var thisMonthSessions: [FocusSession] = []
        var olderSessions: [FocusSession] = []
        
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
            sections.append(FocusDateSection(title: "Today", sessions: todaySessions))
        }
        if !yesterdaySessions.isEmpty {
            sections.append(FocusDateSection(title: "Yesterday", sessions: yesterdaySessions))
        }
        if !thisWeekSessions.isEmpty {
            sections.append(FocusDateSection(title: "This Week", sessions: thisWeekSessions))
        }
        if !thisMonthSessions.isEmpty {
            sections.append(FocusDateSection(title: "This Month", sessions: thisMonthSessions))
        }
        if !olderSessions.isEmpty {
            sections.append(FocusDateSection(title: "Older", sessions: olderSessions))
        }
        
        return sections
    }
    
    // Best week calculation
    private var bestWeek: BestWeek? {
        let calendar = Calendar.current
        var weekCounts: [Date: Int] = [:]
        
        // Only count focus sessions for best week
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        
        for session in focusSessions {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: session.date)?.start ?? session.date
            weekCounts[weekStart, default: 0] += 1
        }
        
        guard let bestWeekStart = weekCounts.max(by: { $0.value < $1.value })?.key,
              let bestWeekCount = weekCounts[bestWeekStart] else {
            return nil
        }
        
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: bestWeekStart) ?? bestWeekStart
        return BestWeek(startDate: bestWeekStart, endDate: weekEnd, focusCount: bestWeekCount)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            searchAndFilterBar
            
            // Content
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
                focusList
            }
        }
        .navigationTitle("Focus History")
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
                    // View mode toggle
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
                        // Focus patterns option
                        Button {
                            showingPatterns = true
                            Haptics.tap()
                        } label: {
                            Label("Focus Patterns", systemImage: "chart.bar.fill")
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
                            shareAllFocusSessions()
                            Haptics.tap()
                        } label: {
                            Label("Share Summary", systemImage: "square.and.arrow.up.on.square")
                        }
                        
                        if !filteredSessions.isEmpty {
                            Divider()
                            
                            Button(role: .destructive) {
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
            FocusHistoryFilterView(
                selectedDateRange: $selectedDateRange,
                customStartDate: $customStartDate,
                customEndDate: $customEndDate
            )
                .iPadOptimizedSheetPresentation()
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportOptionsView(sessions: filteredSessions)
                .iPadOptimizedSheetPresentation()
        }
        .sheet(isPresented: $showingPatterns) {
            FocusPatternsView(sessions: store.sessions)
                .iPadOptimizedSheetPresentation()
        }
        .sheet(item: $selectedSession) { session in
            FocusSessionDetailView(session: session)
                .iPadOptimizedSheetPresentation()
        }
        .confirmationDialog("Delete Focus Session", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
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
            Text("Are you sure you want to delete this focus session? This action can be undone.")
        }
        .confirmationDialog("Delete All Focus Sessions", isPresented: $showingDeleteAllConfirmation, titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                deleteAllFiltered()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete all \(filteredSessions.count) filtered focus session\(filteredSessions.count == 1 ? "" : "s")? This action can be undone.")
        }
        .undoToast()
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Search bar
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search focus sessions...", text: $searchText)
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
                EmptyStateView.noFocusSessions {
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
    
    // MARK: - Focus List
    
    private var focusList: some View {
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
            // Best week highlight
            if let bestWeek = bestWeek {
                Section {
                    BestWeekCard(bestWeek: bestWeek)
                }
            }
            
            // Summary section
            if !filteredSessions.isEmpty {
                Section {
                    FocusHistorySummaryView(sessions: filteredSessions)
                }
            }
            
            // Grouped sessions by date
            if !groupedSessions.isEmpty {
                ForEach(groupedSessions) { section in
                    Section {
                        ForEach(Array(section.sessions.enumerated()), id: \.element.id) { index, session in
                            FocusHistoryRow(session: session)
                                .contentShape(Rectangle())
                                .staggeredEntrance(index: index, delay: 0.04)
                                .cardLift()
                                .onTapGesture {
                                    selectedSession = session
                                    Haptics.buttonPress()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
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
                            let validIndices = indexSet.filter { $0 >= 0 && $0 < section.sessions.count }
                            let sessionsToDelete = validIndices.compactMap { index -> FocusSession? in
                                guard index >= 0 && index < section.sessions.count else { return nil }
                                return section.sessions[index]
                            }
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
                        Text(section.title)
                            .font(.system(size: DesignSystem.Hierarchy.tertiaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                            .allowsTightening(false)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable {
            isLoading = true
            await refreshFocusData()
            isLoading = false
        }
    }
    
    // Timeline view
    private var timelineView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Best week highlight
                if let bestWeek = bestWeek {
                    BestWeekCard(bestWeek: bestWeek)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.lg)
                }
                
                // Summary section
                if !filteredSessions.isEmpty {
                    FocusHistorySummaryView(sessions: filteredSessions)
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
            await refreshFocusData()
            isLoading = false
        }
    }
    
    @MainActor
    private func refreshFocusData() async {
        Haptics.buttonPress()
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay for smooth transition
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func deleteSession(_ session: FocusSession) {
        if let index = store.sessions.firstIndex(where: { $0.id == session.id }) {
            store.deleteSession(at: IndexSet(integer: index))
            
            ToastManager.shared.show(
                message: "Focus session deleted",
                onUndo: {
                    store.undoDelete()
                    Haptics.success()
                }
            )
        }
        
        Haptics.buttonPress()
    }
    
    private func deleteAllFiltered() {
        let sessionsToDelete = filteredSessions
        let indices = sessionsToDelete.compactMap { session in
            store.sessions.firstIndex(where: { $0.id == session.id })
        }
        
        if !indices.isEmpty {
            store.deleteSession(at: IndexSet(indices))
            
            ToastManager.shared.show(
                message: "\(sessionsToDelete.count) focus session\(sessionsToDelete.count == 1 ? "" : "s") deleted",
                onUndo: {
                    store.undoDelete()
                    Haptics.success()
                }
            )
        }
        
        Haptics.buttonPress()
    }
    
    private func shareSession(_ session: FocusSession) {
        // Use FocusShareManager for proper sharing with image and text
        let streak = store.streak
        
        if let window = UIApplication.shared.firstKeyWindow,
           let rootViewController = window.rootViewController {
            FocusShareManager.shared.shareFocusSession(
                session: session,
                streak: streak,
                from: rootViewController
            )
        } else {
            // Fallback: Use basic share if window not available
            FocusShareManager.shared.shareFocusSession(
                session: session,
                streak: streak,
                from: nil
            )
        }
    }
    
    private func shareAllFocusSessions() {
        let focusSessions = filteredSessions.filter { $0.phaseType == .focus }
        let totalFocusSessions = focusSessions.count
        let totalMinutes = focusSessions.reduce(0.0) { $0 + $1.duration } / 60.0
        
        let text = "I've completed \(totalFocusSessions) focus session\(totalFocusSessions == 1 ? "" : "s") with a total of \(Int(totalMinutes)) minutes! 🍅"
        
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let window = UIApplication.shared.firstKeyWindow,
           let rootViewController = window.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = window
            rootViewController.present(activityViewController, animated: true)
        }
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

// MARK: - Focus History Summary View

struct FocusHistorySummaryView: View {
    let sessions: [FocusSession]
    
    private var totalFocusSessions: Int {
        sessions.filter { $0.phaseType == .focus }.count
    }
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
                title: "Focus",
                value: "\(totalFocusSessions)",
                icon: "brain.head.profile",
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

// MARK: - Supporting Types

/// Date section for grouping focus sessions
struct FocusDateSection: Identifiable {
    let id = UUID()
    let title: String
    let sessions: [FocusSession]
}

/// Best week information
struct BestWeek {
    let startDate: Date
    let endDate: Date
    let focusCount: Int
}

// MARK: - Best Week Card

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
                
                Text("\(bestWeek.focusCount) focus session\(bestWeek.focusCount == 1 ? "" : "s")")
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

// MARK: - Timeline Section View

struct TimelineSectionView: View {
    let section: FocusDateSection
    let onSessionTap: (FocusSession) -> Void
    let onDelete: (FocusSession) -> Void
    let onShare: (FocusSession) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
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

// MARK: - Timeline Item View

struct TimelineItemView: View {
    let session: FocusSession
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
                    .fill(phaseColor)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(phaseColor.opacity(0.3), lineWidth: 4)
                            .frame(width: 20, height: 20)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(phaseColor.opacity(0.3))
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
                        .foregroundStyle(phaseColor)
                        .monospacedDigit()
                }
                
                Text(session.phaseType.displayName)
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

// MARK: - Focus Session Detail View

struct FocusSessionDetailView: View {
    let session: FocusSession
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: FocusStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Image(systemName: phaseIcon)
                                .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                                .foregroundStyle(phaseColor)
                            
                            Text("\(session.phaseType.displayName) Complete")
                                .font(Theme.largeTitle)
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text(session.date.formatted(date: .long, time: .shortened))
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, DesignSystem.Spacing.xxl)
                        
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            DetailStatRow(
                                icon: phaseIcon,
                                title: "Phase Type",
                                value: session.phaseType.displayName,
                                color: phaseColor
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
                        
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Button {
                                shareSession()
                                Haptics.tap()
                            } label: {
                                Label("Share Session", systemImage: "square.and.arrow.up")
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
                                Label("Delete Session", systemImage: "trash")
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
            .navigationTitle("Focus Session Details")
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
    
    private var phaseIcon: String {
        switch session.phaseType {
        case .focus:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "bed.double"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func shareSession() {
        let text = "Just completed a \(session.phaseType.displayName.lowercased()) session of \(formatDuration(session.duration))! 🍅"
        
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let window = UIApplication.shared.firstKeyWindow,
           let rootViewController = window.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = window
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    private func deleteSession() {
        if let index = store.sessions.firstIndex(where: { $0.id == session.id }) {
            store.deleteSession(at: IndexSet(integer: index))
        }
    }
}

// MARK: - Focus Patterns View

struct FocusPatternsView: View {
    let sessions: [FocusSession]
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
                        Picker("Pattern Type", selection: $selectedType) {
                            Text("Time of Day").tag(PatternType.timeOfDay)
                            Text("Day of Week").tag(PatternType.dayOfWeek)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.lg)
                        
                        if selectedType == .timeOfDay {
                            timeOfDayChart
                        } else {
                            dayOfWeekChart
                        }
                        
                        insightsCard
                    }
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .navigationTitle("Focus Patterns")
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
            Text("Focus Time Distribution")
                .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            let frequency = calculateTimeOfDayFrequency()
            Chart(TimeOfDay.allCases.filter { $0 != .unknown }) { time in
                BarMark(
                    x: .value("Time", time.displayName),
                    y: .value("Sessions", frequency[time] ?? 0)
                )
                .foregroundStyle(Theme.ringFocus.gradient)
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
            Text("Focus Day Distribution")
                .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            let frequency = calculateDayOfWeekFrequency()
            Chart(DayOfWeek.allCases) { day in
                BarMark(
                    x: .value("Day", day.shortName),
                    y: .value("Sessions", frequency[day] ?? 0)
                )
                .foregroundStyle(Theme.ringBreakShort.gradient)
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
                    color: Theme.ringFocus
                )
            }
            
            if let bestDay = bestDay {
                InsightRow(
                    icon: "calendar",
                    title: "Most Consistent Day",
                    value: bestDay.displayName,
                    color: Theme.ringBreakShort
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
        let focusSessions = sessions.filter { $0.phaseType == .focus }
        
        for session in focusSessions {
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
        let focusSessions = sessions.filter { $0.phaseType == .focus }
        
        for session in focusSessions {
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

// MARK: - Export Options View

struct ExportOptionsView: View {
    let sessions: [FocusSession]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    Text("Export \(sessions.count) Focus Session\(sessions.count == 1 ? "" : "s")")
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
            .navigationTitle("Export Sessions")
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
    let sessions: [FocusSession]
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
                    
                    Text("\(sessions.count) session\(sessions.count == 1 ? "" : "s")")
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
            filename = "focus_sessions_\(Date().formatted(date: .numeric, time: .omitted)).json"
        case .csv:
            data = generateCSV()
            filename = "focus_sessions_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        case .pdf:
            data = nil
            filename = ""
        }
        
        guard let data = data else {
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
        var csv = "Date,Phase Type,Duration (seconds),Completed,Notes\n"
        
        for session in sessions {
            let dateString = session.date.formatted(date: .abbreviated, time: .shortened)
            let duration = Int(session.duration)
            let phaseType = session.phaseType.rawValue
            let completed = session.completed ? "Yes" : "No"
            let notes = session.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            csv += "\(dateString),\(phaseType),\(duration),\(completed),\(notes)\n"
        }
        
        return csv.data(using: .utf8)
    }
}

// MARK: - Supporting Enums

enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    case unknown = "unknown"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        case .unknown: return "Unknown"
        }
    }
}

enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

// MARK: - Detail Stat Row

private struct DetailStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(color)
                .frame(width: DesignSystem.IconSize.medium)
            
            Text(title)
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Insight Row

private struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(color)
                .frame(width: DesignSystem.IconSize.medium)
            
            Text(title)
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}
