import SwiftUI
import Charts

/// Agent 33: Focus Analytics Main View - Comprehensive analytics dashboard
/// Displays overview stats, charts, trends, and insights for focus sessions
struct FocusAnalyticsMainView: View {
    @ObservedObject var analytics: FocusAnalytics
    @EnvironmentObject private var theme: ThemeStore
    @State private var selectedTimeRange: TimeRange = .allTime
    
    enum TimeRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case threeMonths = "90 Days"
        case year = "Year"
        case allTime = "All Time"
        
        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            case .allTime: return nil
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header
                headerSection
                
                // Overview Stats
                overviewStatsSection
                
                // Time Range Selector
                timeRangeSelector
                
                // Charts Section
                chartsSection
                
                // Trends Section
                trendsSection
                
                // Insights Cards
                insightsSection
            }
            .contentPadding()
        }
        .background(ThemeBackground())
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Focus Analytics")
                .font(Theme.title2)
                .foregroundStyle(Theme.textPrimary)
            
            Text("Track your focus patterns and productivity insights")
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .cardPadding()
    }
    
    // MARK: - Overview Stats Section
    
    private var overviewStatsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Overview")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                StatCard(
                    title: "Total Focus Time",
                    value: formatTime(analytics.totalFocusTime),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Sessions",
                    value: "\(analytics.store.totalSessions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(analytics.store.streak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Avg Session",
                    value: formatTime(analytics.averageDuration),
                    icon: "timer",
                    color: .purple
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
    }
    
    // MARK: - Time Range Selector
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .tint(Theme.accent)
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // MARK: - Charts Section
    
    private var chartsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Charts")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weekly Chart
            weeklyChartCard
            
            // Monthly Chart
            monthlyChartCard
            
            // Best Focus Times Chart
            bestFocusTimesCard
            
            // Completion Rate Chart
            completionRateCard
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
    
    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Weekly Trend")
                .font(Theme.subheadline.bold())
                .foregroundStyle(Theme.textPrimary)
            
            if analytics.weeklyTrend.isEmpty {
                emptyChartView(message: "No data for this week")
            } else {
                Chart(analytics.weeklyTrend) { dataPoint in
                    BarMark(
                        x: .value("Day", dayName(for: dataPoint.date)),
                        y: .value("Sessions", dataPoint.count)
                    )
                    .foregroundStyle(Theme.accent.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Theme.textSecondary)
                            .font(Theme.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Theme.textSecondary)
                            .font(Theme.caption)
                    }
                }
            }
        }
    }
    
    private var monthlyChartCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Monthly Trend (Last 30 Days)")
                .font(Theme.subheadline.bold())
                .foregroundStyle(Theme.textPrimary)
            
            if analytics.monthlyTrend.isEmpty {
                emptyChartView(message: "No data for the last 30 days")
            } else {
                Chart(analytics.monthlyTrend) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Sessions", dataPoint.count)
                    )
                    .foregroundStyle(Theme.accent)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Sessions", dataPoint.count)
                    )
                    .foregroundStyle(Theme.accent.gradient.opacity(0.3))
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisValueLabel(format: .dateTime.month().day(), centered: true)
                            .foregroundStyle(Theme.textSecondary)
                            .font(Theme.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Theme.textSecondary)
                            .font(Theme.caption)
                    }
                }
            }
        }
    }
    
    private var bestFocusTimesCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Best Focus Times")
                .font(Theme.subheadline.bold())
                .foregroundStyle(Theme.textPrimary)
            
            let frequencyByTime = analytics.focusFrequencyByTime
            
            if frequencyByTime.isEmpty {
                emptyChartView(message: "No focus time data available")
            } else {
                Chart(TimeOfDay.allCases.filter { $0 != .unknown }) { timeOfDay in
                    BarMark(
                        x: .value("Time", timeOfDay.displayName),
                        y: .value("Count", frequencyByTime[timeOfDay] ?? 0)
                    )
                    .foregroundStyle(colorForTimeOfDay(timeOfDay).gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Theme.textSecondary)
                            .font(Theme.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Theme.textSecondary)
                            .font(Theme.caption)
                    }
                }
            }
        }
    }
    
    private var completionRateCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Completion Rate")
                    .font(Theme.subheadline.bold())
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Text("\(Int(analytics.averageCompletionRate))%")
                    .font(Theme.title3.bold())
                    .foregroundStyle(Theme.accent)
            }
            
            ProgressView(value: analytics.averageCompletionRate / 100.0)
                .tint(Theme.accent)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(Theme.accent.opacity(0.1))
        )
    }
    
    // MARK: - Trends Section
    
    private var trendsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Trends & Comparisons")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Week Comparison
            comparisonCard(
                title: "This Week vs Last Week",
                recent: analytics.progress7Days.recent,
                previous: analytics.progress7Days.previous,
                change: analytics.progress7Days.change
            )
            
            // Month Comparison
            comparisonCard(
                title: "Last 30 Days vs Previous 30 Days",
                recent: analytics.progress30Days.recent,
                previous: analytics.progress30Days.previous,
                change: analytics.progress30Days.change
            )
            
            // Frequency Trend
            frequencyTrendCard(trend: analytics.getFrequencyTrend())
            
            // Consistency Trend
            consistencyTrendCard(trend: analytics.getConsistencyTrend())
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
    
    private func comparisonCard(title: String, recent: Int, previous: Int, change: Double) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(Theme.subheadline.bold())
                .foregroundStyle(Theme.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(recent)")
                        .font(Theme.title2.bold())
                        .foregroundStyle(Theme.textPrimary)
                    Text("Recent")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(previous)")
                        .font(Theme.title2.bold())
                        .foregroundStyle(Theme.textPrimary)
                    Text("Previous")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(Theme.caption.bold())
                    Text("\(abs(Int(change)))%")
                        .font(Theme.subheadline.bold())
                }
                .foregroundStyle(change >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(Theme.accent.opacity(0.1))
        )
    }
    
    private func frequencyTrendCard(trend: FrequencyTrend) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Frequency Trend")
                    .font(Theme.subheadline.bold())
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                trendIndicator(direction: trend.direction)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(trend.recentPeriod)")
                        .font(Theme.title3.bold())
                    Text("Recent Period")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(trend.previousPeriod)")
                        .font(Theme.title3.bold())
                    Text("Previous Period")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(Theme.accent.opacity(0.1))
        )
    }
    
    private func consistencyTrendCard(trend: ConsistencyTrend) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Consistency")
                    .font(Theme.subheadline.bold())
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
                
                Text(consistencyLevelString(trend.level))
                    .font(Theme.caption.bold())
                    .foregroundStyle(consistencyColor(trend.level))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(consistencyColor(trend.level).opacity(0.2))
                    )
            }
            
            ProgressView(value: trend.consistencyScore)
                .tint(consistencyColor(trend.level))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("Avg \(String(format: "%.1f", trend.averageSessionsPerDay)) sessions/day")
                .font(Theme.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(Theme.accent.opacity(0.1))
        )
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Quick Insights")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let insights = analytics.generateInsights()
            
            if insights.isEmpty {
                emptyInsightsView
            } else {
                ForEach(insights.prefix(3)) { insight in
                    AnalyticsInsightCard(insight: insight)
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
    
    private var emptyInsightsView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(Theme.title)
                .foregroundStyle(.secondary)
            
            Text("Complete more focus sessions to see insights")
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Helper Views
    
    private func emptyChartView(message: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "chart.bar.xaxis")
                .font(Theme.title2)
                .foregroundStyle(.secondary)
            Text(message)
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private func trendIndicator(direction: TrendDirection) -> some View {
        HStack(spacing: 4) {
            Image(systemName: directionIcon(direction))
                .font(Theme.caption.bold())
            Text(directionString(direction))
                .font(Theme.caption.bold())
        }
        .foregroundStyle(directionColor(direction))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(directionColor(direction).opacity(0.2))
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func colorForTimeOfDay(_ timeOfDay: TimeOfDay) -> Color {
        switch timeOfDay {
        case .morning: return .yellow
        case .afternoon: return .orange
        case .evening: return .purple
        case .night: return .blue
        case .unknown: return .gray
        }
    }
    
    private func directionIcon(_ direction: TrendDirection) -> String {
        switch direction {
        case .improving: return "arrow.up.right"
        case .declining: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    private func directionString(_ direction: TrendDirection) -> String {
        switch direction {
        case .improving: return "Improving"
        case .declining: return "Declining"
        case .stable: return "Stable"
        }
    }
    
    private func directionColor(_ direction: TrendDirection) -> Color {
        switch direction {
        case .improving: return .green
        case .declining: return .red
        case .stable: return .orange
        }
    }
    
    private func consistencyLevelString(_ level: ConsistencyLevel) -> String {
        switch level {
        case .veryConsistent: return "Very Consistent"
        case .consistent: return "Consistent"
        case .moderate: return "Moderate"
        case .inconsistent: return "Inconsistent"
        }
    }
    
    private func consistencyColor(_ level: ConsistencyLevel) -> Color {
        switch level {
        case .veryConsistent: return .green
        case .consistent: return .blue
        case .moderate: return .orange
        case .inconsistent: return .red
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(Theme.title2.bold())
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Insight Card Component

struct AnalyticsInsightCard: View {
    let insight: FocusInsight
    
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: insight.icon)
                .font(Theme.title3)
                .foregroundStyle(insight.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(Theme.subheadline.bold())
                    .foregroundStyle(Theme.textPrimary)
                
                Text(insight.message)
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(insight.color.opacity(0.1))
        )
    }
}


