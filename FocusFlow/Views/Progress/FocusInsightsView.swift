import SwiftUI

/// Agent 34: Focus Insights View - Comprehensive insights dashboard
/// Replaces placeholder in FocusContentView.swift:310
/// Provides personalized insights, recommendations, patterns, and predictions
struct FocusInsightsView: View {
    @ObservedObject var analytics: FocusAnalytics
    @EnvironmentObject private var theme: ThemeStore
    @EnvironmentObject private var store: FocusStore
    
    @StateObject private var insightsManager: FocusInsightsManager
    @StateObject private var trendAnalyzer: FocusTrendAnalyzer
    @StateObject private var predictiveAnalytics: PredictiveFocusAnalytics
    
    @State private var selectedTimeRange: InsightsTimeRange = .all
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init(analytics: FocusAnalytics) {
        self._analytics = ObservedObject(wrappedValue: analytics)
        self._insightsManager = StateObject(wrappedValue: FocusInsightsManager(analytics: analytics))
        self._trendAnalyzer = StateObject(wrappedValue: FocusTrendAnalyzer(store: analytics.store))
        self._predictiveAnalytics = StateObject(wrappedValue: PredictiveFocusAnalytics(store: analytics.store))
    }
    
    var body: some View {
        ZStack {
            ThemeBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    header
                    
                    // Time Range Selector
                    timeRangeSelector
                    
                    // Personalized Insights Section
                    personalizedInsightsSection
                    
                    // Recommendations Section
                    recommendationsSection
                    
                    // Patterns Section
                    patternsSection
                    
                    // Predictions Section
                    predictionsSection
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .padding(.top, horizontalSizeClass == .regular ? DesignSystem.Spacing.xl : DesignSystem.Spacing.lg)
                .padding(.horizontal, horizontalSizeClass == .regular ? DesignSystem.Spacing.xxl : DesignSystem.Spacing.lg)
                .frame(maxWidth: horizontalSizeClass == .regular ? DesignSystem.Screen.maxContentWidth : .infinity)
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Your Focus Insights")
                .font(.system(size: DesignSystem.Hierarchy.primaryTitle, weight: DesignSystem.Hierarchy.primaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            
            Text("Personalized insights based on your focus patterns")
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    // MARK: - Time Range Selector
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            Text("All Time").tag(InsightsTimeRange.all)
            Text("7 Days").tag(InsightsTimeRange.week)
            Text("30 Days").tag(InsightsTimeRange.month)
            Text("90 Days").tag(InsightsTimeRange.quarter)
            Text("Year").tag(InsightsTimeRange.year)
        }
        .pickerStyle(.segmented)
        .tint(Theme.accentA)
        .padding(.horizontal, DesignSystem.Spacing.xs)
    }
    
    // MARK: - Personalized Insights Section
    
    private var personalizedInsightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            SectionHeader(
                title: "Personalized Insights",
                icon: "sparkles",
                color: Theme.accentA
            )
            
            let insights = insightsManager.generateProductivityInsights()
            
            if insights.isEmpty {
                emptyStateCard(
                    icon: "chart.bar.xaxis",
                    message: "Complete more focus sessions to see personalized insights"
                )
            } else {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(insights.prefix(4)) { insight in
                        ProductivityInsightCard(insight: insight)
                    }
                }
            }
        }
    }
    
    // MARK: - Recommendations Section
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            SectionHeader(
                title: "Recommendations",
                icon: "lightbulb.fill",
                color: Theme.accentB
            )
            
            let recommendations = insightsManager.getRecommendations()
            let tips = insightsManager.getProductivityTips()
            
            if recommendations.isEmpty && tips.isEmpty {
                emptyStateCard(
                    icon: "lightbulb",
                    message: "Recommendations will appear as we learn more about your focus patterns"
                )
            } else {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Actionable Recommendations
                    if !recommendations.isEmpty {
                        ForEach(recommendations) { recommendation in
                            ProductivityRecommendationCard(recommendation: recommendation)
                        }
                    }
                    
                    // Productivity Tips
                    if !tips.isEmpty {
                        ForEach(Array(tips.prefix(3).enumerated()), id: \.offset) { _, tip in
                            TipCard(tip: tip)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Patterns Section
    
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            SectionHeader(
                title: "Patterns",
                icon: "chart.line.uptrend.xyaxis",
                color: Theme.accentC
            )
            
            // Time of Day Patterns
            if let optimalTime = predictiveAnalytics.predictOptimalFocusTime() {
                PatternCard(
                    title: "Best Focus Time",
                    icon: "clock.fill",
                    color: Theme.accentA,
                    content: {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("\(optimalTime.timeOfDay.displayName)")
                                .font(Theme.title3.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text("\(optimalTime.sessionCount) sessions at this time")
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if optimalTime.averageCompletionRate > 0 {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(Theme.caption)
                                        .foregroundStyle(.green)
                                    Text("\(Int(optimalTime.averageCompletionRate * 100))% completion rate")
                                        .font(Theme.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                )
            }
            
            // Day of Week Patterns
            dayOfWeekPatternCard
            
            // Consistency Pattern
            let consistencyTrend = trendAnalyzer.analyzeConsistencyTrend()
            PatternCard(
                title: "Consistency",
                icon: "calendar.badge.clock",
                color: Theme.accentB,
                content: {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(consistencyLevelDescription(consistencyTrend.level))
                            .font(Theme.title3.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("Score: \(Int(consistencyTrend.consistencyScore * 100))%")
                            .font(Theme.subheadline)
                            .foregroundStyle(.secondary)
                        
                        ProgressView(value: consistencyTrend.consistencyScore)
                            .tint(Theme.accentB)
                            .frame(height: 6)
                    }
                }
            )
            
            // Frequency Trend
            let frequencyTrend = trendAnalyzer.analyzeFrequencyTrend()
            PatternCard(
                title: "Frequency Trend",
                icon: frequencyTrend.direction == .improving ? "arrow.up.right" : (frequencyTrend.direction == .declining ? "arrow.down.right" : "arrow.right"),
                color: frequencyTrend.direction == .improving ? .green : (frequencyTrend.direction == .declining ? .red : .gray),
                content: {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(frequencyTrend.direction == .improving ? "Improving" : (frequencyTrend.direction == .declining ? "Declining" : "Stable"))
                            .font(Theme.title3.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        HStack(spacing: DesignSystem.Spacing.md) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Recent")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(frequencyTrend.recentPeriod)")
                                    .font(Theme.title3)
                                    .foregroundStyle(Theme.textPrimary)
                                    .monospacedDigit()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Previous")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(frequencyTrend.previousPeriod)")
                                    .font(Theme.title3)
                                    .foregroundStyle(Theme.textPrimary)
                                    .monospacedDigit()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                Text("Change")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: frequencyTrend.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(Theme.caption)
                                    Text("\(Int(abs(frequencyTrend.change)))%")
                                        .font(Theme.title3)
                                        .monospacedDigit()
                                }
                                .foregroundStyle(frequencyTrend.change >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            )
        }
    }
    
    // MARK: - Day of Week Pattern Card
    
    private var dayOfWeekPatternCard: some View {
        let calendar = Calendar.current
        let focusSessions = store.sessions.filter { $0.phaseType == .focus }
        
        var dayCounts: [Int: Int] = [:]
        for session in focusSessions {
            let weekday = calendar.component(.weekday, from: session.date)
            dayCounts[weekday, default: 0] += 1
        }
        
        let maxDay = dayCounts.max(by: { $0.value < $1.value })?.key ?? 1
        let maxCount = dayCounts[maxDay] ?? 0
        
        if maxCount > 0, let dayOfWeek = DayOfWeek(rawValue: maxDay) {
            return AnyView(
                PatternCard(
                    title: "Most Productive Day",
                    icon: "calendar",
                    color: Theme.accentC,
                    content: {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text(dayOfWeek.displayName)
                                .font(Theme.title3.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text("\(maxCount) focus session\(maxCount == 1 ? "" : "s") on \(dayOfWeek.displayName)")
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    // MARK: - Predictions Section
    
    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            SectionHeader(
                title: "Predictions",
                icon: "crystal.ball.fill",
                color: Theme.accentA
            )
            
            let todayLikelihood = predictiveAnalytics.predictFocusLikelihoodToday()
            
            // Today's Focus Likelihood
            PredictionCard(
                title: "Today's Focus Likelihood",
                icon: "calendar.badge.clock",
                color: Theme.accentA,
                content: {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Text(todayLikelihood.description)
                                .font(Theme.title2.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(todayLikelihood.percentage)%")
                                .font(Theme.title2.weight(.bold))
                                .foregroundStyle(Theme.accentA)
                                .monospacedDigit()
                        }
                        
                        ProgressView(value: todayLikelihood.probability)
                            .tint(Theme.accentA)
                            .frame(height: 8)
                        
                        if !todayLikelihood.factors.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("Factors:")
                                    .font(Theme.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                
                                ForEach(todayLikelihood.factors, id: \.self) { factor in
                                    HStack(spacing: DesignSystem.Spacing.xs) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 4))
                                            .foregroundStyle(.secondary)
                                        Text(factor)
                                            .font(Theme.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Confidence indicator
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: confidenceIcon(todayLikelihood.confidence))
                                .font(Theme.caption)
                                .foregroundStyle(confidenceColor(todayLikelihood.confidence))
                            Text("\(todayLikelihood.confidence.displayName) confidence")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            )
            
            // Optimal Time Prediction
            if let optimalTime = predictiveAnalytics.predictOptimalFocusTime() {
                PredictionCard(
                    title: "Optimal Focus Time",
                    icon: "clock.fill",
                    color: Theme.accentB,
                    content: {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text(formatHour(optimalTime.hour))
                                .font(Theme.title2.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Text("Based on \(optimalTime.sessionCount) session\(optimalTime.sessionCount == 1 ? "" : "s")")
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: confidenceIcon(optimalTime.confidence))
                                    .font(Theme.caption)
                                    .foregroundStyle(confidenceColor(optimalTime.confidence))
                                Text("\(optimalTime.confidence.displayName) confidence")
                                    .font(Theme.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func emptyStateCard(icon: String, message: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.xxlarge))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                )
        )
    }
    
    private func consistencyLevelDescription(_ level: ConsistencyLevel) -> String {
        switch level {
        case .veryConsistent: return "Very Consistent"
        case .consistent: return "Consistent"
        case .moderate: return "Moderate"
        case .inconsistent: return "Inconsistent"
        }
    }
    
    private func confidenceIcon(_ confidence: Confidence) -> String {
        switch confidence {
        case .high: return "checkmark.circle.fill"
        case .medium: return "checkmark.circle"
        case .low: return "questionmark.circle"
        }
    }
    
    private func confidenceColor(_ confidence: Confidence) -> Color {
        switch confidence {
        case .high: return .green
        case .medium: return .orange
        case .low: return .gray
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = 0
        
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        
        return "\(hour):00"
    }
}

// MARK: - Supporting Views

private struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(Theme.title3)
                .foregroundStyle(color)
            
            Text(title)
                .font(.system(size: DesignSystem.Hierarchy.secondaryTitle, weight: DesignSystem.Hierarchy.secondaryWeight, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
}

private struct ProductivityInsightCard: View {
    let insight: ProductivityInsight
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(insight.color.opacity(DesignSystem.Opacity.highlight * 0.3))
                    .frame(width: DesignSystem.IconSize.xxlarge, height: DesignSystem.IconSize.xxlarge)
                
                Image(systemName: insight.icon)
                    .font(Theme.title3)
                    .foregroundStyle(insight.color)
            }
            .accessibilityHidden(true)
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(insight.title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(insight.message)
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .cardPadding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                insight.color.opacity(DesignSystem.Opacity.highlight * 0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(insight.color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
            )
        )
        .softShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(insight.title). \(insight.message)")
    }
}

private struct ProductivityRecommendationCard: View {
    let recommendation: ProductivityRecommendation
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: recommendation.icon)
                .font(Theme.title3)
                .foregroundStyle(Theme.accentB)
                .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(recommendation.title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(recommendation.message)
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Action would be implemented based on recommendation type
                Haptics.tap()
            }) {
                Text(recommendation.action)
                    .font(Theme.caption.weight(.semibold))
                    .foregroundStyle(Theme.accentB)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(Theme.accentB.opacity(DesignSystem.Opacity.highlight * 0.3))
                    )
            }
            .accessibilityLabel(recommendation.action)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                )
        )
        .softShadow()
    }
}

private struct TipCard: View {
    let tip: String
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(Theme.title3)
                .foregroundStyle(.yellow)
                .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            
            Text(tip)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                )
        )
        .softShadow()
    }
}

private struct PatternCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(Theme.title3)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
            }
            
            content
        }
        .cardPadding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(DesignSystem.Opacity.highlight * 0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
            )
        )
        .softShadow()
    }
}

private struct PredictionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(Theme.title3)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Spacer()
            }
            
            content
        }
        .cardPadding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(DesignSystem.Opacity.highlight * 0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
            )
        )
        .softShadow()
    }
}

// MARK: - Supporting Types

private enum InsightsTimeRange: String, CaseIterable {
    case all = "all"
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
}

extension Confidence {
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}


