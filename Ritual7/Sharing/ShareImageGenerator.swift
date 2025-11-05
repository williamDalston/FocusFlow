import SwiftUI
import UIKit

/// Agent 12: Social Features & Sharing - Generate beautiful shareable images for workouts, streaks, achievements, and progress
@MainActor
enum ShareImageGenerator {
    
    // MARK: - Workout Completion Image
    
    /// Generate a beautiful image for workout completion with stats
    static func generateWorkoutCompletionImage(
        duration: TimeInterval,
        exercisesCompleted: Int,
        calories: Int? = nil,
        streak: Int = 0,
        date: Date = Date(),
        scale: CGFloat = 2.0
    ) -> UIImage {
        let view = WorkoutCompletionShareView(
            duration: duration,
            exercisesCompleted: exercisesCompleted,
            calories: calories,
            streak: streak,
            date: date
        )
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = max(1.0, min(4.0, scale))
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    // MARK: - Streak Image
    
    /// Generate a beautiful image for streak sharing
    static func generateStreakImage(
        streak: Int,
        totalWorkouts: Int = 0,
        scale: CGFloat = 2.0
    ) -> UIImage {
        let view = StreakShareView(
            streak: streak,
            totalWorkouts: totalWorkouts
        )
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = max(1.0, min(4.0, scale))
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    // MARK: - Achievement Image
    
    /// Generate a beautiful image for achievement sharing
    static func generateAchievementImage(
        title: String,
        description: String,
        icon: String = "trophy.fill",
        scale: CGFloat = 2.0
    ) -> UIImage {
        let view = AchievementShareView(
            title: title,
            description: description,
            icon: icon
        )
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = max(1.0, min(4.0, scale))
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    // MARK: - Progress Chart Image
    
    /// Generate a progress chart visualization for sharing
    static func generateProgressChartImage(
        weeklyData: [DailyWorkoutCount],
        monthlyData: [MonthlyWorkoutCount]? = nil,
        scale: CGFloat = 2.0
    ) -> UIImage {
        let view = ProgressChartShareView(
            weeklyData: weeklyData,
            monthlyData: monthlyData
        )
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = max(1.0, min(4.0, scale))
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
    
    // MARK: - Summary Image
    
    /// Generate a comprehensive workout summary image
    static func generateSummaryImage(
        totalWorkouts: Int,
        streak: Int,
        totalMinutes: TimeInterval,
        estimatedCalories: Int,
        scale: CGFloat = 2.0
    ) -> UIImage {
        let view = SummaryShareView(
            totalWorkouts: totalWorkouts,
            streak: streak,
            totalMinutes: totalMinutes,
            estimatedCalories: estimatedCalories
        )
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = max(1.0, min(4.0, scale))
        renderer.isOpaque = true
        
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - Workout Completion Share View

private struct WorkoutCompletionShareView: View {
    let duration: TimeInterval
    let exercisesCompleted: Int
    let calories: Int?
    let streak: Int
    let date: Date
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                
                Text("Workout Complete!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Stats
                VStack(spacing: 20) {
                    StatRow(
                        icon: "clock.fill",
                        label: "Time",
                        value: formatDuration(duration)
                    )
                    
                    StatRow(
                        icon: "figure.run",
                        label: "Exercises",
                        value: "\(exercisesCompleted)/12"
                    )
                    
                    if let calories = calories {
                        StatRow(
                            icon: "flame.fill",
                            label: "Calories",
                            value: "~\(calories)"
                        )
                    }
                    
                    if streak > 0 {
                        StatRow(
                            icon: "flame.fill",
                            label: "Streak",
                            value: "\(streak) days"
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 60)
                
                // Footer
                HStack {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Ritual7")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .compositingGroup()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.3, saturation: 0.7, brightness: 0.3), // green
                Color(hue: 0.35, saturation: 0.6, brightness: 0.25), // olive
                Color(hue: 0.4, saturation: 0.5, brightness: 0.2) // dark green
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Streak Share View

private struct StreakShareView: View {
    let streak: Int
    let totalWorkouts: Int
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                Spacer(minLength: 80)
                
                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 20)
                
                Text("\(streak)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Day Streak!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                if totalWorkouts > 0 {
                    Text("\(totalWorkouts) total workouts")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer(minLength: 80)
                
                // Footer
                HStack {
                    Text("Keep it going! 💪")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Ritual7")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .compositingGroup()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.05, saturation: 0.8, brightness: 0.3), // orange-red
                Color(hue: 0.08, saturation: 0.7, brightness: 0.25), // deep orange
                Color(hue: 0.12, saturation: 0.6, brightness: 0.2) // dark orange
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Achievement Share View

private struct AchievementShareView: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                Spacer(minLength: 80)
                
                // Trophy icon
                Image(systemName: icon)
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                
                Text("Achievement Unlocked!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text(description)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer(minLength: 80)
                
                // Footer
                HStack {
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Ritual7")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .compositingGroup()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.15, saturation: 0.7, brightness: 0.3), // yellow-gold
                Color(hue: 0.18, saturation: 0.6, brightness: 0.25), // deep gold
                Color(hue: 0.22, saturation: 0.5, brightness: 0.2) // dark gold
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Progress Chart Share View

private struct ProgressChartShareView: View {
    let weeklyData: [DailyWorkoutCount]
    let monthlyData: [MonthlyWorkoutCount]?
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 24) {
                Spacer(minLength: 60)
                
                Text("Workout Progress")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Weekly chart
                if !weeklyData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(Array(weeklyData.enumerated()), id: \.offset) { offset, day in
                                VStack(spacing: 4) {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .cyan],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 40, height: CGFloat(day.count * 30 + 20))
                                        .cornerRadius(8)
                                    
                                    Text(day.date.formatted(.dateTime.weekday(.abbreviated)))
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Text("\(day.count)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer(minLength: 60)
                
                // Footer
                HStack {
                    Text("Keep going! 💪")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Ritual7")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .compositingGroup()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.55, saturation: 0.7, brightness: 0.3), // blue
                Color(hue: 0.58, saturation: 0.6, brightness: 0.25), // deep blue
                Color(hue: 0.62, saturation: 0.5, brightness: 0.2) // dark blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Summary Share View

private struct SummaryShareView: View {
    let totalWorkouts: Int
    let streak: Int
    let totalMinutes: TimeInterval
    let estimatedCalories: Int
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                Text("My Workout Summary")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Stats grid
                VStack(spacing: 20) {
                    StatRow(
                        icon: "figure.run",
                        label: "Total Workouts",
                        value: "\(totalWorkouts)"
                    )
                    
                    StatRow(
                        icon: "flame.fill",
                        label: "Current Streak",
                        value: "\(streak) days"
                    )
                    
                    StatRow(
                        icon: "clock.fill",
                        label: "Total Time",
                        value: formatTotalTime(totalMinutes)
                    )
                    
                    StatRow(
                        icon: "flame.fill",
                        label: "Calories Burned",
                        value: "~\(estimatedCalories)"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 60)
                
                // Footer
                HStack {
                    Text("Keep it up! 💪")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Ritual7")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .compositingGroup()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.69, saturation: 0.72, brightness: 0.22), // deep purple
                Color(hue: 0.78, saturation: 0.68, brightness: 0.30), // blue-violet
                Color(hue: 0.83, saturation: 0.60, brightness: 0.28) // indigo
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func formatTotalTime(_ minutes: TimeInterval) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

// MARK: - Supporting Views

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 40)
            
            Text(label)
                .font(.system(size: 18, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, DesignSystem.Spacing.formFieldSpacing)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: DesignSystem.Border.standard)
                )
        )
    }
}

