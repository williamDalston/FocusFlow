import SwiftUI
import Charts

/// Agent 10: Comparison View - Compare workouts across different time periods
struct ComparisonView: View {
    @ObservedObject var analytics: WorkoutAnalytics
    @ObservedObject var trendAnalyzer: TrendAnalyzer
    @EnvironmentObject private var theme: ThemeStore
    @State private var selectedComparison: ComparisonType = .week
    
    enum ComparisonType: String, CaseIterable {
        case week = "This Week vs Last Week"
        case month = "This Month vs Last Month"
        case period = "Last 30 Days vs Previous 30 Days"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Comparison Type Selector
            Picker("Comparison", selection: $selectedComparison) {
                ForEach(ComparisonType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            // Comparison Chart
            switch selectedComparison {
            case .week:
                weekComparisonChart
            case .month:
                monthComparisonChart
            case .period:
                periodComparisonChart
            }
            
            // Comparison Summary
            comparisonSummary
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
    }
    
    // MARK: - Week Comparison Chart
    
    private var weekComparisonChart: some View {
        let comparison = trendAnalyzer.compareThisWeekVsLastWeek()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Comparison")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart {
                BarMark(
                    x: .value("Period", "Last Week"),
                    y: .value("Workouts", comparison.lastWeek)
                )
                .foregroundStyle(Theme.accentA.opacity(0.6))
                .cornerRadius(DesignSystem.CornerRadius.small)
                
                BarMark(
                    x: .value("Period", "This Week"),
                    y: .value("Workouts", comparison.thisWeek)
                )
                .foregroundStyle(Theme.accentB.gradient)
                .cornerRadius(DesignSystem.CornerRadius.small)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            
            // Change indicator
            HStack {
                Image(systemName: comparison.isImproving ? "arrow.up.right" : "arrow.down.right")
                    .foregroundStyle(comparison.isImproving ? .green : .red)
                Text("\(comparison.isImproving ? "+" : "")\(comparison.changePercentage)%")
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(comparison.isImproving ? .green : .red)
                Text("vs last week")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Month Comparison Chart
    
    private var monthComparisonChart: some View {
        let comparison = trendAnalyzer.compareThisMonthVsLastMonth()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Comparison")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart {
                BarMark(
                    x: .value("Period", "Last Month"),
                    y: .value("Workouts", comparison.lastMonth)
                )
                .foregroundStyle(Theme.accentA.opacity(0.6))
                .cornerRadius(DesignSystem.CornerRadius.small)
                
                BarMark(
                    x: .value("Period", "This Month"),
                    y: .value("Workouts", comparison.thisMonth)
                )
                .foregroundStyle(Theme.accentC.gradient)
                .cornerRadius(DesignSystem.CornerRadius.small)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            
            // Change indicator
            HStack {
                Image(systemName: comparison.isImproving ? "arrow.up.right" : "arrow.down.right")
                    .foregroundStyle(comparison.isImproving ? .green : .red)
                Text("\(comparison.isImproving ? "+" : "")\(comparison.changePercentage)%")
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(comparison.isImproving ? .green : .red)
                Text("vs last month")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Period Comparison Chart
    
    private var periodComparisonChart: some View {
        let trend = trendAnalyzer.analyzeFrequencyTrend()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("30-Day Period Comparison")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Chart {
                BarMark(
                    x: .value("Period", "Previous 15 Days"),
                    y: .value("Workouts", trend.previousPeriod)
                )
                .foregroundStyle(Theme.accentA.opacity(0.6))
                .cornerRadius(DesignSystem.CornerRadius.small)
                
                BarMark(
                    x: .value("Period", "Recent 15 Days"),
                    y: .value("Workouts", trend.recentPeriod)
                )
                .foregroundStyle(Theme.accentB.gradient)
                .cornerRadius(DesignSystem.CornerRadius.small)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            
            // Trend indicator
            HStack {
                Image(systemName: trend.direction.icon)
                    .foregroundStyle(trend.direction.color)
                Text(trend.direction.description)
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(trend.direction.color)
                Text("\(trend.changePercentage > 0 ? "+" : "")\(trend.changePercentage)%")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Comparison Summary
    
    private var comparisonSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            let weekComparison = trendAnalyzer.compareThisWeekVsLastWeek()
            let monthComparison = trendAnalyzer.compareThisMonthVsLastMonth()
            let trend = trendAnalyzer.analyzeFrequencyTrend()
            
            ComparisonSummaryRow(
                title: "Weekly",
                value1: weekComparison.lastWeek,
                value2: weekComparison.thisWeek,
                change: weekComparison.change,
                isImproving: weekComparison.isImproving
            )
            
            ComparisonSummaryRow(
                title: "Monthly",
                value1: monthComparison.lastMonth,
                value2: monthComparison.thisMonth,
                change: monthComparison.change,
                isImproving: monthComparison.isImproving
            )
            
            ComparisonSummaryRow(
                title: "30-Day Trend",
                value1: trend.previousPeriod,
                value2: trend.recentPeriod,
                change: trend.change,
                isImproving: trend.direction == .improving
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
    }
}

// MARK: - Comparison Summary Row

private struct ComparisonSummaryRow: View {
    let title: String
    let value1: Int
    let value2: Int
    let change: Double
    let isImproving: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.subheadline.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(value1)")
                    .font(Theme.caption)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "arrow.right")
                    .font(Theme.caption2)
                    .foregroundStyle(.secondary)
                
                Text("\(value2)")
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("(\(isImproving ? "+" : "")\(Int(abs(change)))%)")
                    .font(Theme.caption.weight(.semibold))
                    .foregroundStyle(isImproving ? .green : .red)
            }
        }
    }
}

