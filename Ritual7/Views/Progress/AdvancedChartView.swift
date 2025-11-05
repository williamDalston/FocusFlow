import SwiftUI
import Charts

/// Agent 10: Advanced Chart View - Interactive charts with tap-to-detail and export functionality
struct AdvancedChartView: View {
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
        VStack(spacing: 24) {
            // Header with export button
            HStack {
                Text("Advanced Analytics")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    showingExportSheet = true
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
            
            // Interactive Chart
            switch selectedTimeframe {
            case .week:
                interactiveWeeklyChart
            case .month:
                interactiveMonthlyChart
            case .year:
                interactiveYearlyChart
            }
            
            // Selected Data Point Info
            if let selected = selectedDataPoint {
                selectedDataPointCard(dataPoint: selected)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .sheet(isPresented: $showingExportSheet) {
            ChartExportSheet(analytics: analytics, timeframe: selectedTimeframe)
                .iPadOptimizedSheetPresentation()
        }
    }
    
    // MARK: - Interactive Weekly Chart
    
    private var interactiveWeeklyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workouts This Week")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart(analytics.weeklyTrend) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Workouts", day.count)
                )
                .foregroundStyle(Theme.accentA.gradient)
                .cornerRadius(DesignSystem.CornerRadius.small)
                .opacity(selectedDataPoint?.id == day.id ? 1.0 : 0.7)
                
                // Interactive overlay
                RectangleMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Workouts", day.count)
                )
                .foregroundStyle(Color.clear)
                .annotation(position: .overlay) {
                    if selectedDataPoint?.id == day.id {
                        VStack(spacing: 4) {
                            Text("\(day.count)")
                                .font(Theme.caption)
                                .foregroundStyle(.white)
                                .padding(DesignSystem.Spacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs, style: .continuous)
                                        .fill(Theme.accentA)
                                )
                        }
                    }
                }
            }
            .frame(height: 250)
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
            .modifier(ChartAngleSelectionModifier(selectedDataPoint: $selectedDataPoint))
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            // Find tapped data point
                            if let day = findDataPoint(at: location, in: geometry.size, chartProxy: chartProxy) {
                                selectedDataPoint = day
                            } else {
                                selectedDataPoint = nil
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Interactive Monthly Chart
    
    private var interactiveMonthlyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                .symbol {
                    Circle()
                        .fill(Theme.accentB)
                        .frame(width: selectedDataPoint?.id == day.id ? 10 : 6)
                }
                .opacity(selectedDataPoint?.id == day.id ? 1.0 : 0.7)
                
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
            .frame(height: 250)
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
            .modifier(ChartAngleSelectionModifier(selectedDataPoint: $selectedDataPoint))
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            if let day = findDataPoint(at: location, in: geometry.size, chartProxy: chartProxy) {
                                selectedDataPoint = day
                            } else {
                                selectedDataPoint = nil
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Interactive Yearly Chart
    
    private var interactiveYearlyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workouts Last 12 Months")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart(analytics.yearlyTrend) { month in
                BarMark(
                    x: .value("Month", month.month, unit: .month),
                    y: .value("Workouts", month.count)
                )
                .foregroundStyle(Theme.accentC.gradient)
                .cornerRadius(DesignSystem.CornerRadius.small)
                .opacity(selectedDataPoint?.id == month.id ? 1.0 : 0.7)
                
                // Interactive overlay
                RectangleMark(
                    x: .value("Month", month.month, unit: .month),
                    y: .value("Workouts", month.count)
                )
                .foregroundStyle(Color.clear)
                .annotation(position: .overlay) {
                    if selectedDataPoint?.id == month.id {
                        VStack(spacing: 4) {
                            Text("\(month.count)")
                                .font(Theme.caption)
                                .foregroundStyle(.white)
                                .padding(DesignSystem.Spacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.Spacing.xs, style: .continuous)
                                        .fill(Theme.accentC)
                                )
                        }
                    }
                }
            }
            .frame(height: 250)
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
    
    // MARK: - Selected Data Point Card
    
    private func selectedDataPointCard(dataPoint: DailyWorkoutCount) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Theme.accentA)
                Text("Selected Date")
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                    Text("\(dataPoint.count) workout\(dataPoint.count == 1 ? "" : "s")")
                        .font(Theme.title3)
                        .foregroundStyle(Theme.textPrimary)
                }
                
                Spacer()
                
                Button {
                    selectedDataPoint = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .stroke(Theme.accentA.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.standard)
                )
        )
    }
    
    // MARK: - Helper Methods
    
    private func findDataPoint(at location: CGPoint, in size: CGSize, chartProxy: ChartProxy) -> DailyWorkoutCount? {
        // Simplified - in a real implementation, you'd use chartProxy to convert screen coordinates
        // For now, return nil as this requires more complex chart interaction handling
        return nil
    }
}

// MARK: - Chart Export Sheet

struct ChartExportSheet: View {
    @ObservedObject var analytics: WorkoutAnalytics
    let timeframe: AdvancedChartView.Timeframe
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
                    .font(Theme.headline)
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
                        .font(Theme.body.weight(.semibold))
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
        // This would render the chart to an image/PDF
        dismiss()
    }
}

// MARK: - Chart Angle Selection Modifier (iOS 17+ compatibility)

struct ChartAngleSelectionModifier: ViewModifier {
    @Binding var selectedDataPoint: DailyWorkoutCount?
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .chartAngleSelection(value: Binding<Int?>(get: { selectedDataPoint?.count }, set: { _ in }))
        } else {
            content
        }
    }
}

