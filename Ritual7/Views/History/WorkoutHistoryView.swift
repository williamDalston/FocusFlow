import SwiftUI

/// Agent 1: Missing Views - Comprehensive workout history view with filtering, search, export, and share
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
        
        return sessions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            searchAndFilterBar
            
            // Content
            if filteredSessions.isEmpty {
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
                Menu {
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
                            deleteAllFiltered()
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
        .sheet(item: $selectedSession) { session in
            WorkoutSessionDetailView(session: session)
        }
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
        List {
            // Summary section
            if !filteredSessions.isEmpty {
                Section {
                    WorkoutHistorySummaryView(sessions: filteredSessions)
                }
            }
            
            // Sessions list
            Section {
                ForEach(Array(filteredSessions.enumerated()), id: \.element.id) { index, session in
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
                                deleteSession(session)
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
                    store.deleteSession(at: indexSet)
                    Haptics.buttonPress()
                }
            } header: {
                Text("Workouts (\(filteredSessions.count))")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable {
            // Pull-to-refresh: reload workout data
            await refreshWorkoutData()
        }
    }
    
    @MainActor
    private func refreshWorkoutData() async {
        // Trigger haptic feedback
        Haptics.buttonPress()
        
        // Reload workout store data
        // The WorkoutStore will automatically refresh when accessed
        // This is a placeholder for any async refresh logic if needed
        try? await Task.sleep(nanoseconds: 100_000_000) // Small delay for visual feedback
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func deleteSession(_ session: WorkoutSession) {
        if let index = store.sessions.firstIndex(where: { $0.id == session.id }) {
            store.deleteSession(at: IndexSet(integer: index))
        }
    }
    
    private func deleteAllFiltered() {
        let indices = filteredSessions.compactMap { session in
            store.sessions.firstIndex(where: { $0.id == session.id })
        }
        store.deleteSession(at: IndexSet(indices))
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

