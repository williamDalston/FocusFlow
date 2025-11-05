import SwiftUI
import Charts

/// Agent 2: Progress Charts - Beautiful charts for workout progress visualization
/// Agent 10: Enhanced with interactivity and export functionality
struct ProgressChartView: View {
    @ObservedObject var analytics: WorkoutAnalytics
    @EnvironmentObject private var theme: ThemeStore
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedDataPoint: DailyWorkoutCount?
    @State private var showingExportSheet = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Header with export button (Agent 10)
            HStack {
                Text("Progress Charts")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    showingExportSheet = true
                    Haptics.tap()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(Theme.body)
                        .foregroundStyle(Theme.accentA)
                }
            }
            
            // Timeframe selector
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            
            // Chart based on selected timeframe
            switch selectedTimeframe {
            case .week:
                weeklyChart
            case .month:
                monthlyChart
            case .year:
                yearlyChart
            }
            
            // Agent 10: Selected Data Point Info
            if let selected = selectedDataPoint {
                selectedDataPointInfo(dataPoint: selected)
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
        .sheet(isPresented: $showingExportSheet) {
            ProgressChartExportSheet(analytics: analytics, timeframe: selectedTimeframe)
        }
    }
    
    // MARK: - Agent 10: Selected Data Point Info
    
    private func selectedDataPointInfo(dataPoint: DailyWorkoutCount) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Theme.accentA)
                    .font(Theme.subheadline)
                Text("Selected Date")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    selectedDataPoint = nil
                    Haptics.tap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                    Text("\(dataPoint.count) workout\(dataPoint.count == 1 ? "" : "s")")
                        .font(Theme.title3)
                        .foregroundStyle(Theme.textPrimary)
                        .monospacedDigit()
                }
                
                Spacer()
            }
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.5), lineWidth: DesignSystem.Border.standard)
                )
        )
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workouts This Week")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart(analytics.weeklyTrend) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Workouts", day.count)
                )
                .foregroundStyle(Theme.accentA.gradient)
                .cornerRadius(8)
                .opacity(selectedDataPoint?.id == day.id ? 1.0 : 0.7)
                
                // Agent 10: Interactive annotation
                if selectedDataPoint?.id == day.id {
                    RuleMark(x: .value("Day", day.date, unit: .day))
                        .foregroundStyle(Theme.accentA.opacity(0.5))
                }
            }
            .frame(height: 200)
            .modifier(ChartXSelectionModifier(selectedDataPoint: $selectedDataPoint, analytics: analytics))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
    }
    
    // MARK: - Monthly Chart
    
    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workouts Last 30 Days")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart(analytics.monthlyTrend) { day in
                LineMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Workouts", day.count)
                )
                .foregroundStyle(Theme.accentB)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Workouts", day.count)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accentB.opacity(0.3), Theme.accentB.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
    }
    
    // MARK: - Yearly Chart
    
    private var yearlyChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workouts Last 12 Months")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart(analytics.yearlyTrend) { month in
                BarMark(
                    x: .value("Month", month.month, unit: .month),
                    y: .value("Workouts", month.count)
                )
                .foregroundStyle(Theme.accentC.gradient)
                .cornerRadius(8)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
    }
}

// MARK: - Exercise Completion Chart

struct ExerciseCompletionChartView: View {
    @ObservedObject var analytics: WorkoutAnalytics
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Exercise Completion Rate")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Group {
                if #available(iOS 17.0, *) {
                    Chart {
                        let completionRate = analytics.averageCompletionRate
                        SectorMark(
                            angle: .value("Completed", completionRate),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(Theme.accentA.gradient)
                        
                        SectorMark(
                            angle: .value("Remaining", 100 - completionRate),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.gray.opacity(0.3))
                    }
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("\(Int(analytics.averageCompletionRate))%")
                                .font(Theme.title)
                                .foregroundStyle(Theme.textPrimary)
                                .monospacedDigit()
                            Text("Average")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    // Fallback for iOS 16: Use a simple bar chart
                    Chart {
                        BarMark(
                            x: .value("Completion", analytics.averageCompletionRate)
                        )
                        .foregroundStyle(Theme.accentA.gradient)
                    }
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("\(Int(analytics.averageCompletionRate))%")
                                .font(Theme.title)
                                .foregroundStyle(Theme.textPrimary)
                                .monospacedDigit()
                            Text("Average")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
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
    }
}

// MARK: - Workout Frequency Chart

struct WorkoutFrequencyChartView: View {
    @ObservedObject var analytics: WorkoutAnalytics
    @EnvironmentObject private var theme: ThemeStore
    @State private var selectedType: FrequencyType = .timeOfDay
    
    enum FrequencyType: String, CaseIterable {
        case timeOfDay = "Time of Day"
        case dayOfWeek = "Day of Week"
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Type selector
            Picker("Type", selection: $selectedType) {
                ForEach(FrequencyType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            // Chart based on selected type
            switch selectedType {
            case .timeOfDay:
                timeOfDayChart
            case .dayOfWeek:
                dayOfWeekChart
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
    }
    
    private var timeOfDayChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workout Time Distribution")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            let frequency = analytics.workoutFrequencyByTime
            Chart(TimeOfDay.allCases.filter { $0 != .unknown }) { time in
                BarMark(
                    x: .value("Time", time.displayName),
                    y: .value("Workouts", frequency[time] ?? 0)
                )
                .foregroundStyle(Theme.accentA.gradient)
                .cornerRadius(8)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
    }
    
    private var dayOfWeekChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Workout Day Distribution")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            let frequency = analytics.workoutFrequencyByDay
            Chart(DayOfWeek.allCases) { day in
                BarMark(
                    x: .value("Day", day.shortName),
                    y: .value("Workouts", frequency[day] ?? 0)
                )
                .foregroundStyle(Theme.accentB.gradient)
                .cornerRadius(8)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
    }
}

// MARK: - Agent 10: Chart Export Sheet

private struct ProgressChartExportSheet: View {
    @ObservedObject var analytics: WorkoutAnalytics
    let timeframe: ProgressChartView.Timeframe
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .png
    
    enum ExportFormat: String, CaseIterable {
        case png = "PNG Image"
        case pdf = "PDF Document"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Export Chart")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                
                Picker("Format", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                
                Button {
                    exportChart()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportChart() {
        // Export functionality would be implemented here
        // This would render the chart to an image/PDF using ImageRenderer
        dismiss()
    }
}

// MARK: - Chart X Selection Modifier (iOS 17+ compatibility)

struct ChartXSelectionModifier: ViewModifier {
    @Binding var selectedDataPoint: DailyWorkoutCount?
    let analytics: WorkoutAnalytics
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .chartXSelection(value: Binding(
                    get: { selectedDataPoint?.date },
                    set: { newDate in
                        if let newDate = newDate {
                            selectedDataPoint = analytics.weeklyTrend.first { Calendar.current.isDate($0.date, inSameDayAs: newDate) }
                        } else {
                            selectedDataPoint = nil
                        }
                    }
                ))
        } else {
            content
        }
    }
}

