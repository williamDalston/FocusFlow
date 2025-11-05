import SwiftUI

/// Agent 11: Completion Celebration View - Enhanced completion screen with animations and detailed stats
/// Provides a rewarding experience after workout completion

struct CompletionCelebrationView: View {
    let workoutStats: WorkoutCompletionStats
    let onDismiss: () -> Void
    let onStartNew: () -> Void
    
    @State private var showStats = false
    @State private var showAchievements = false
    @State private var animationPhase: Int = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Celebration header
                    celebrationHeader
                    
                    // Stats grid
                    if showStats {
                        statsGrid
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Achievement unlocks
                    if showAchievements && !workoutStats.unlockedAchievements.isEmpty {
                        achievementsSection
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Next workout suggestion
                    nextWorkoutSuggestion
                    
                    // Action buttons
                    actionButtons
                }
                .padding(32)
            }
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    // MARK: - Celebration Header
    
    private var celebrationHeader: some View {
        VStack(spacing: 24) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animationPhase >= 1 ? 1.0 : 0.5)
                    .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(animationPhase >= 2 ? 1.0 : 0.5)
                    .opacity(animationPhase >= 2 ? 1.0 : 0.0)
            }
            
            VStack(spacing: 12) {
                Text("Workout Complete!")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    .opacity(animationPhase >= 3 ? 1.0 : 0.0)
                
                Text(completionMessage)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(animationPhase >= 3 ? 1.0 : 0.0)
            }
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Duration",
                value: formatDuration(workoutStats.duration),
                icon: "clock.fill",
                color: Theme.accentA
            )
            
            StatCard(
                title: "Exercises",
                value: "\(workoutStats.exercisesCompleted)",
                icon: "figure.run",
                color: Theme.accentB
            )
            
            StatCard(
                title: "Calories",
                value: "~\(workoutStats.estimatedCalories)",
                icon: "flame.fill",
                color: Theme.accentC
            )
            
            if workoutStats.repsCompleted > 0 {
                StatCard(
                    title: "Reps",
                    value: "\(workoutStats.repsCompleted)",
                    icon: "repeat",
                    color: Theme.accentA
                )
            }
        }
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements Unlocked!")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            
            ForEach(workoutStats.unlockedAchievements, id: \.self) { achievement in
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.title3)
                    
                    Text(achievement)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.opacity(0.1))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Next Workout Suggestion
    
    private var nextWorkoutSuggestion: some View {
        VStack(spacing: 12) {
            Text("Keep Going!")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            
            Text(suggestionMessage)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.1))
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onStartNew()
            } label: {
                Label("Start New Workout", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            
            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
    }
    
    // MARK: - Helpers
    
    private var completionMessage: String {
        if workoutStats.isPersonalBest {
            return "Personal best! You're getting stronger! 💪"
        } else if workoutStats.isStreakDay {
            return "Day \(workoutStats.currentStreak) of your streak! 🔥"
        } else {
            return "Great job completing your workout!"
        }
    }
    
    private var suggestionMessage: String {
        if workoutStats.currentStreak >= 7 {
            return "You're on fire! Keep your streak going tomorrow."
        } else if workoutStats.currentStreak > 0 {
            return "You're building a great habit! Work out again tomorrow to grow your streak."
        } else {
            return "Start a streak by working out again tomorrow!"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startCelebrationAnimation() {
        // Phase 1: Circle appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animationPhase = 1
            }
        }
        
        // Phase 2: Checkmark appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animationPhase = 2
            }
        }
        
        // Phase 3: Text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeIn(duration: 0.4)) {
                animationPhase = 3
            }
        }
        
        // Phase 4: Stats appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showStats = true
            }
        }
        
        // Phase 5: Achievements appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showAchievements = true
            }
        }
    }
}

// MARK: - Supporting Types

struct WorkoutCompletionStats {
    let duration: TimeInterval
    let exercisesCompleted: Int
    let estimatedCalories: Int
    let repsCompleted: Int
    let currentStreak: Int
    let isStreakDay: Bool
    let isPersonalBest: Bool
    let unlockedAchievements: [String]
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.1))
        )
    }
}

