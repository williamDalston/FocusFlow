import Foundation

// MARK: - Progress Comparison Types

/// Progress comparison between two time periods
struct ProgressComparison {
    let recent: Int
    let previous: Int
    let change: Double // Percentage change
}

// MARK: - Optimal Time Prediction Types

/// Prediction for optimal focus time
struct OptimalTimePrediction {
    let hour: Int
    let timeOfDay: String
    let workoutCount: Int
    let averageCompletionRate: Double
    let confidence: Confidence
}

// MARK: - Frequency Trend Types

/// Trend direction for frequency analysis
enum TrendDirection {
    case improving
    case declining
    case stable
}

/// Confidence level for trend analysis
enum Confidence {
    case high
    case medium
    case low
}

/// Frequency trend analysis result
struct FrequencyTrend {
    let recentPeriod: Int
    let previousPeriod: Int
    let change: Double // Percentage change
    let direction: TrendDirection
    let confidence: Confidence
}

// MARK: - Consistency Trend Types

/// Consistency level for trend analysis
enum ConsistencyLevel {
    case veryConsistent
    case consistent
    case moderate
    case inconsistent
}

/// Consistency trend analysis result
struct ConsistencyTrend {
    let consistencyScore: Double
    let level: ConsistencyLevel
    let averageWorkoutsPerDay: Double
    let standardDeviation: Double
}

// MARK: - Goal Achievement Prediction Types

/// Goal achievement prediction
struct GoalAchievementPrediction {
    let goal: Int
    let current: Int
    let predicted: Int
    let probability: Double
    let confidence: Confidence
    let workoutsNeeded: Int
    let recommendedDaily: Double
}

// MARK: - Correlation Analysis Types

/// Correlation analysis result
struct CorrelationAnalysis {
    let morningCompletionRate: Double
    let afternoonCompletionRate: Double
    let eveningCompletionRate: Double
    let bestTime: CorrelationTimeOfDay
}

/// Time of day enum for correlation analysis
enum CorrelationTimeOfDay {
    case morning
    case afternoon
    case evening
}

// MARK: - Comparison Types

/// Week comparison result
struct WeekComparison {
    let thisWeek: Int
    let lastWeek: Int
    let change: Double
}

/// Month comparison result
struct MonthComparison {
    let thisMonth: Int
    let lastMonth: Int
    let change: Double
}

// MARK: - Performance Trend Types

/// Performance trend result
struct PerformanceTrend {
    let trend: TrendDirection
    let change: Double
    let confidence: Confidence
}

// MARK: - Personalized Recommendation Types

/// Personalized recommendation
struct PersonalizedRecommendation {
    let type: RecommendationType
    let title: String
    let description: String
    let priority: Int
}

/// Recommendation type
enum RecommendationType {
    case frequency
    case consistency
    case timing
    case duration
    case goal
    case optimalTime
}

