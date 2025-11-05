import SwiftUI
import Charts
import HealthKit

/// Agent 13: Health Trends View - Displays health insights and trends
struct HealthTrendsView: View {
    @StateObject private var insightsManager = HealthInsightsManager.shared
    @StateObject private var recoveryAnalyzer = RecoveryAnalyzer.shared
    @StateObject private var healthKitStore = HealthKitStore.shared
    
    @State private var selectedTab = 0
    @State private var isLoading = true
    @State private var currentInsight: HealthInsight?
    @State private var recoveryAnalysis: RecoveryAnalysis?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Tabs
                tabPicker
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        insightsTab
                    case 1:
                        recoveryTab
                    case 2:
                        trendsTab
                    default:
                        insightsTab
                    }
                }
            }
            .padding()
        }
        .background(ThemeBackground())
        .navigationTitle("Health Insights")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadData()
        }
        .enhancedRefreshable {
            await loadData()
        }
        .toastContainer()
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            if !healthKitStore.isAuthorized {
                GlassCard(material: .ultraThinMaterial) {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                            .foregroundStyle(Theme.accentA)
                        
                        Text("Enable HealthKit")
                            .font(Theme.title2)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("Connect with Apple Health to get personalized health insights and track your fitness progress.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        NavigationLink {
                            HealthKitPermissionsView()
                        } label: {
                            Text("Enable HealthKit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accentA)
                        .padding(.top, 8)
                    }
                    .padding(DesignSystem.Spacing.cardPadding)
                }
            } else {
                if isLoading {
                    LoadingStateView(message: "Loading health data...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
    
    // MARK: - Tab Picker
    
    private var tabPicker: some View {
        Picker("View", selection: $selectedTab) {
            Text("Insights").tag(0)
            Text("Recovery").tag(1)
            Text("Trends").tag(2)
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Insights Tab
    
    private var insightsTab: some View {
        VStack(spacing: 24) {
            if let insight = currentInsight {
                // Summary Cards
                HStack(spacing: 16) {
                    HealthTrendsInsightCard(
                        title: "Workouts",
                        value: "\(insight.workoutsCount)",
                        icon: "figure.run",
                        color: Theme.accentA
                    )
                    
                    HealthTrendsInsightCard(
                        title: "Calories",
                        value: "\(Int(insight.totalCaloriesBurned))",
                        icon: "flame.fill",
                        color: Theme.accentB
                    )
                }
                
                // Consistency Score
                if insight.consistencyScore > 0 {
                    GlassCard(material: .ultraThinMaterial) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Consistency Score")
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)
                            
                            HStack {
                                ProgressView(value: insight.consistencyScore, total: 1.0)
                                    .tint(Theme.accentA)
                                
                                Text("\(Int(insight.consistencyScore * 100))%")
                                    .font(.headline)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            
                            Text(consistencyDescription(score: insight.consistencyScore))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(DesignSystem.Spacing.formFieldSpacing)
                    }
                }
                
                // Heart Rate Info
                if let avgHR = insight.averageHeartRate {
                    GlassCard(material: .ultraThinMaterial) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Average Heart Rate")
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)
                            
                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                Text("\(Int(avgHR))")
                                    .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                                    .foregroundStyle(Theme.accentA)
                                
                                Text("BPM")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let restingHR = insight.restingHeartRate {
                                Text("Resting: \(Int(restingHR)) BPM")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(DesignSystem.Spacing.formFieldSpacing)
                    }
                }
                
                // Improvement Trend
                GlassCard(material: .ultraThinMaterial) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Improvement Trend")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        HStack {
                            Image(systemName: trendIcon(for: insight.improvementTrend))
                                .font(.title2)
                                .foregroundStyle(trendColor(for: insight.improvementTrend))
                            
                            Text(insight.improvementTrend.rawValue)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        
                        Text(trendDescription(for: insight.improvementTrend))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(DesignSystem.Spacing.formFieldSpacing)
                }
                
                // Recommendations
                if !insight.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommendations")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        ForEach(insight.recommendations) { recommendation in
                            HealthTrendsRecommendationCard(recommendation: recommendation)
                        }
                    }
                }
            } else if !isLoading {
                Text("No insights available")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Recovery Tab
    
    private var recoveryTab: some View {
        VStack(spacing: 24) {
            if let analysis = recoveryAnalysis {
                // Training Load
                GlassCard(material: .ultraThinMaterial) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Training Load")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        HStack {
                            ProgressView(value: analysis.trainingLoad.score, total: 100)
                                .tint(loadColor(for: analysis.trainingLoad.level))
                            
                            Text("\(Int(analysis.trainingLoad.score))%")
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)
                        }
                        
                        Text(analysis.trainingLoad.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(DesignSystem.Spacing.formFieldSpacing)
                }
                
                // Readiness Score
                GlassCard(material: .ultraThinMaterial) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Readiness Score")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("\(Int(analysis.readinessScore))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(readinessColor(score: analysis.readinessScore))
                            
                            Text("/ 100")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(readinessDescription(score: analysis.readinessScore))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(DesignSystem.Spacing.formFieldSpacing)
                }
                
                // Recovery Time
                GlassCard(material: .ultraThinMaterial) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Recovery")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        let hours = analysis.recommendedRecoveryTime / 3600
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("\(Int(hours))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Theme.accentB)
                            
                            Text(hours == 1 ? "hour" : "hours")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Before your next intense workout")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(DesignSystem.Spacing.formFieldSpacing)
                }
                
                // Recommendations
                if !analysis.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recovery Recommendations")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        ForEach(analysis.recommendations) { recommendation in
                            HealthTrendsRecommendationCard(recommendation: recommendation)
                        }
                    }
                }
            } else if !isLoading {
                Text("No recovery data available")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Trends Tab
    
    private var trendsTab: some View {
        VStack(spacing: 24) {
            if !insightsManager.healthTrends.isEmpty {
                // Weekly Trends Chart
                GlassCard(material: .ultraThinMaterial) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Workouts")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Chart(insightsManager.healthTrends) { trend in
                            BarMark(
                                x: .value("Week", trend.date, unit: .weekOfYear),
                                y: .value("Workouts", trend.workoutsCount)
                            )
                            .foregroundStyle(Theme.accentA.gradient)
                        }
                        .frame(height: 200)
                    }
                    .padding(DesignSystem.Spacing.formFieldSpacing)
                }
                
                // Calories Chart
                GlassCard(material: .ultraThinMaterial) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Calories Burned")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        Chart(insightsManager.healthTrends) { trend in
                            LineMark(
                                x: .value("Week", trend.date, unit: .weekOfYear),
                                y: .value("Calories", trend.totalCalories)
                            )
                            .foregroundStyle(Theme.accentB)
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Week", trend.date, unit: .weekOfYear),
                                y: .value("Calories", trend.totalCalories)
                            )
                            .foregroundStyle(Theme.accentB.opacity(0.2).gradient)
                        }
                        .frame(height: 200)
                    }
                    .padding(DesignSystem.Spacing.formFieldSpacing)
                }
            } else if !isLoading {
                Text("No trend data available")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        guard healthKitStore.isAuthorized else { return }
        
        do {
            let insight = try await insightsManager.analyzeWorkoutImpact()
            currentInsight = insight
            
            let analysis = try await recoveryAnalyzer.analyzeRecoveryNeeds()
            recoveryAnalysis = analysis
            
            try await insightsManager.fetchHealthTrends()
        } catch {
            print("Failed to load health data: \(error.localizedDescription)")
        }
    }
    
    private func consistencyDescription(score: Double) -> String {
        if score >= 0.8 {
            return "Excellent consistency! You're maintaining great workout habits."
        } else if score >= 0.6 {
            return "Good consistency. Keep it up!"
        } else if score >= 0.4 {
            return "Moderate consistency. Try to work out more frequently."
        } else {
            return "Low consistency. Aim for more regular workouts."
        }
    }
    
    private func trendIcon(for trend: ImprovementTrend) -> String {
        switch trend {
        case .improving:
            return "arrow.up.circle.fill"
        case .declining:
            return "arrow.down.circle.fill"
        case .stable:
            return "arrow.right.circle.fill"
        case .insufficientData:
            return "questionmark.circle.fill"
        }
    }
    
    private func trendColor(for trend: ImprovementTrend) -> Color {
        switch trend {
        case .improving:
            return .green
        case .declining:
            return .orange
        case .stable:
            return .blue
        case .insufficientData:
            return .gray
        }
    }
    
    private func trendDescription(for trend: ImprovementTrend) -> String {
        switch trend {
        case .improving:
            return "Your fitness is improving! Your heart rate patterns show you're getting fitter."
        case .declining:
            return "Your heart rate patterns suggest you may need more recovery."
        case .stable:
            return "Your fitness level is stable."
        case .insufficientData:
            return "Not enough data to determine trend."
        }
    }
    
    private func loadColor(for level: TrainingLoadLevel) -> Color {
        switch level {
        case .low:
            return .blue
        case .moderate:
            return .green
        case .high:
            return .orange
        case .veryHigh:
            return .red
        }
    }
    
    private func readinessColor(score: Double) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .yellow
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func readinessDescription(score: Double) -> String {
        if score >= 80 {
            return "Excellent readiness! You're ready for an intense workout."
        } else if score >= 60 {
            return "Good readiness. You can work out, but consider a moderate session."
        } else if score >= 40 {
            return "Moderate readiness. Consider a light workout or rest day."
        } else {
            return "Low readiness. Rest is recommended."
        }
    }
}

// MARK: - Supporting Views

private struct HealthTrendsInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}

private struct HealthTrendsRecommendationCard: View {
    let title: String
    let message: String
    let action: String?
    let priority: Priority
    
    enum Priority {
        case low, medium, high
    }
    
    init(recommendation: HealthRecommendation) {
        self.title = recommendation.title
        self.message = recommendation.message
        self.action = recommendation.action
        self.priority = Priority(from: recommendation.priority)
    }
    
    init(recommendation: RecoveryRecommendation) {
        self.title = recommendation.title
        self.message = recommendation.message
        self.action = recommendation.action
        self.priority = Priority(from: recommendation.priority)
    }
    
    var body: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(colorForPriority(priority))
                    
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let action = action {
                    Text(action)
                        .font(.caption)
                        .foregroundStyle(Theme.accentA)
                        .padding(.top, 4)
                }
            }
            .padding(DesignSystem.Spacing.formFieldSpacing)
        }
    }
    
    private func colorForPriority(_ priority: Priority) -> Color {
        switch priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

extension HealthTrendsRecommendationCard.Priority {
    init(from priority: HealthRecommendation.Priority) {
        switch priority {
        case .low:
            self = .low
        case .medium:
            self = .medium
        case .high:
            self = .high
        }
    }
    
    init(from priority: RecoveryRecommendation.Priority) {
        switch priority {
        case .low:
            self = .low
        case .medium:
            self = .medium
        case .high:
            self = .high
        }
    }
}

// MARK: - Extensions for RecoveryRecommendation

// RecoveryRecommendation already conforms to Identifiable (has id: UUID property)

