import SwiftUI

/// Agent 2: Insights View - Personalized insights and recommendations
/// Agent 15: Updated to use FocusAnalytics
struct InsightsView: View {
    @ObservedObject var analytics: FocusAnalytics
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header
                header
                
                // Insights list
                insightsList
                
                // Progress comparison
                progressComparison
                
                // Recommendations
                recommendations
            }
            .contentPadding()
        }
        .background(ThemeBackground())
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Your Focus Insights")
                .font(Theme.title2)
                .foregroundStyle(Theme.textPrimary)
            
            Text("Personalized insights based on your focus patterns")
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .cardPadding()
    }
    
    // MARK: - Insights List
    
    private var insightsList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Key Insights")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            let insights = analytics.generateInsights()
            
            if insights.isEmpty {
                emptyInsights
            } else {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
    
    private var emptyInsights: some View {
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
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle * 0.5))
        )
    }
    
    // MARK: - Progress Comparison
    
    private var progressComparison: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Progress Comparison")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            // This week vs last week
            comparisonCard(
                title: "This Week vs Last Week",
                recent: analytics.progress7Days.recent,
                previous: analytics.progress7Days.previous,
                change: analytics.progress7Days.change
            )
            
            // This month vs last month
            comparisonCard(
                title: "Last 30 Days vs Previous 30 Days",
                recent: analytics.progress30Days.recent,
                previous: analytics.progress30Days.previous,
                change: analytics.progress30Days.change
            )
        }
    }
    
    private func comparisonCard(title: String, recent: Int, previous: Int, change: Double) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Recent")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                    Text("\(recent)")
                        .font(Theme.title3)
                        .foregroundStyle(Theme.textPrimary)
                        .monospacedDigit()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Previous")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                    Text("\(previous)")
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
                        Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(Theme.caption)
                        Text("\(abs(Int(change)))%")
                            .font(Theme.title3)
                            .monospacedDigit()
                    }
                    .foregroundStyle(change >= 0 ? .green : .red)
                }
            }
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.subtle), 
               radius: DesignSystem.Shadow.small.radius, 
               y: DesignSystem.Shadow.small.y)
    }
    
    // MARK: - Recommendations
    
    private var recommendations: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("Recommendations")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            ForEach(generateRecommendations(), id: \.self) { recommendation in
                RecommendationCard(recommendation: recommendation)
            }
        }
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        // Streak recommendations
        if analytics.store.streak < 3 {
            recommendations.append("Build a 3-day streak to maintain momentum!")
        } else if analytics.store.streak < 7 {
            recommendations.append("You're close to a week-long streak! Keep going!")
        }
        
        // Frequency recommendations
        if analytics.store.sessionsThisWeek < 3 {
            recommendations.append("Try to complete 3 focus sessions this week for better results.")
        }
        
        // Time of day recommendations
        if analytics.bestFocusTime == .morning {
            recommendations.append("You focus best in the morning. Keep this routine!")
        } else if analytics.bestFocusTime == .evening {
            recommendations.append("Evening focus sessions work well for you. Consider making it a habit!")
        }
        
        // Completion rate recommendations
        if analytics.averageCompletionRate < 80 {
            recommendations.append("Try to complete all focus sessions for maximum benefit!")
        }
        
        return recommendations.isEmpty ? ["Keep up the great work!"] : recommendations
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: FocusInsight
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Icon
            Image(systemName: insight.icon)
                .font(Theme.title2)
                .foregroundStyle(insight.color)
                .frame(width: DesignSystem.IconSize.xxlarge, height: DesignSystem.IconSize.xxlarge)
                .background(
                    Circle()
                        .fill(insight.color.opacity(DesignSystem.Opacity.subtle))
                )
            
            // Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(insight.title)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(insight.message)
                    .font(Theme.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(insight.color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
                )
        )
        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.subtle), 
               radius: DesignSystem.Shadow.small.radius, 
               y: DesignSystem.Shadow.small.y)
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: String
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(Theme.title3)
                .foregroundStyle(.yellow)
                .frame(width: DesignSystem.IconSize.statBox, height: DesignSystem.IconSize.statBox)
            
            Text(recommendation)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.subtle), 
               radius: DesignSystem.Shadow.small.radius, 
               y: DesignSystem.Shadow.small.y)
    }
}


