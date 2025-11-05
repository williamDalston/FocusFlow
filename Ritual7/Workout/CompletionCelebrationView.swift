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
    @State private var confettiTrigger1 = false
    @State private var confettiTrigger2 = false
    @State private var confettiTrigger3 = false
    @State private var victoryLapScale: CGFloat = 0.8
    @State private var victoryLapRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.85),
                    Theme.accentA.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Multiple confetti bursts
            ConfettiView(trigger: $confettiTrigger1)
            ConfettiView(trigger: $confettiTrigger2)
            ConfettiView(trigger: $confettiTrigger3)
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    // Celebration header with victory lap
                    celebrationHeader
                        .scaleEffect(victoryLapScale)
                        .rotationEffect(.degrees(victoryLapRotation))
                    
                    // Stats grid with staggered animation
                    if showStats {
                        statsGrid
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Achievement unlocks with enhanced animation
                    if showAchievements && !workoutStats.unlockedAchievements.isEmpty {
                        achievementsSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Next workout suggestion
                    nextWorkoutSuggestion
                    
                    // Action buttons
                    actionButtons
                }
                .padding(DesignSystem.Spacing.xxl)
            }
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    // MARK: - Celebration Header
    
    private var celebrationHeader: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Enhanced animated checkmark with glow effect
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(0.4 - Double(index) * 0.1),
                                    Theme.accentB.opacity(0.3 - Double(index) * 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                        .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                        .blur(radius: CGFloat(index * 2))
                }
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB, Theme.accentC],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(animationPhase >= 1 ? 1.0 : 0.3)
                    .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                    .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.medium), 
                           radius: DesignSystem.Shadow.large.radius, 
                           y: DesignSystem.Shadow.large.y)
                
                // Checkmark with pulse
                Image(systemName: "checkmark")
                    .font(.system(size: DesignSystem.IconSize.huge * 1.2, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(animationPhase >= 2 ? 1.0 : 0.3)
                    .opacity(animationPhase >= 2 ? 1.0 : 0.0)
                    .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Workout Complete!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(animationPhase >= 3 ? 1.0 : 0.0)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text(completionMessage)
                    .font(Theme.title2)
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.almostOpaque))
                    .multilineTextAlignment(.center)
                    .opacity(animationPhase >= 3 ? 1.0 : 0.0)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.md) {
            ForEach(Array(statsArray.enumerated()), id: \.element.id) { index, stat in
                StatCard(
                    title: stat.title,
                    value: stat.value,
                    icon: stat.icon,
                    color: stat.color
                )
                .staggeredEntrance(index: index, delay: 0.1)
            }
        }
    }
    
    private var statsArray: [(id: String, title: String, value: String, icon: String, color: Color)] {
        var stats: [(id: String, title: String, value: String, icon: String, color: Color)] = [
            ("duration", "Duration", formatDuration(workoutStats.duration), "clock.fill", Theme.accentA),
            ("exercises", "Exercises", "\(workoutStats.exercisesCompleted)", "figure.run", Theme.accentB),
            ("calories", "Calories", "~\(workoutStats.estimatedCalories)", "flame.fill", Theme.accentC)
        ]
        
        if workoutStats.repsCompleted > 0 {
            stats.append(("reps", "Reps", "\(workoutStats.repsCompleted)", "repeat", Theme.accentA))
        }
        
        return stats
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements Unlocked!")
                .font(Theme.headline)
                .foregroundStyle(.white)
            
            ForEach(workoutStats.unlockedAchievements, id: \.self) { achievement in
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(Theme.title3)
                    
                    Text(achievement)
                        .font(Theme.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .fill(.white.opacity(DesignSystem.Opacity.subtle * 1.0))
                        
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(DesignSystem.Opacity.highlight * 1.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.overlay)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(DesignSystem.Opacity.light * 1.2),
                                        Color.white.opacity(DesignSystem.Opacity.subtle),
                                        Color.white.opacity(DesignSystem.Opacity.light * 1.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: DesignSystem.Border.subtle
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .stroke(Color.white.opacity(DesignSystem.Opacity.glow * 0.8), lineWidth: DesignSystem.Border.hairline)
                            .blur(radius: 1)
                    )
                )
                .shadow(color: Color.white.opacity(DesignSystem.Opacity.subtle), 
                       radius: DesignSystem.Shadow.verySoft.radius, 
                       y: DesignSystem.Shadow.verySoft.y)
            }
        }
        .padding(DesignSystem.Spacing.formFieldSpacing)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Next Workout Suggestion
    
    private var nextWorkoutSuggestion: some View {
        VStack(spacing: 12) {
            Text("Keep Going!")
                .font(Theme.headline)
                .foregroundStyle(.white)
            
            Text(suggestionMessage)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.formFieldSpacing)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.white.opacity(DesignSystem.Opacity.subtle))
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                // Show interstitial ad after workout completion
                // Small delay to let user see the completion screen first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    InterstitialAdManager.shared.present(from: nil)
                }
                onStartNew()
            } label: {
                Label("Start New Workout", systemImage: "arrow.clockwise")
                    .font(Theme.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            
            Button {
                // Show interstitial ad after workout completion
                // Small delay to let user see the completion screen first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    InterstitialAdManager.shared.present(from: nil)
                }
                onDismiss()
            } label: {
                Text("Done")
                    .font(Theme.headline)
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
        // Initial confetti burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            confettiTrigger1 = true
        }
        
        // Phase 1: Circle appears with victory lap
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(AnimationConstants.smoothSpring) {
                animationPhase = 1
            }
            // Victory lap animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                victoryLapScale = 1.0
                victoryLapRotation = 360
            }
        }
        
        // Second confetti burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            confettiTrigger2 = true
        }
        
        // Phase 2: Checkmark appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(AnimationConstants.smoothSpring) {
                animationPhase = 2
            }
        }
        
        // Phase 3: Text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(AnimationConstants.quickEase) {
                animationPhase = 3
            }
        }
        
        // Phase 4: Stats appear with staggered entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(AnimationConstants.elegantSpring) {
                showStats = true
            }
            // Third confetti burst when stats appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                confettiTrigger3 = true
            }
        }
        
        // Phase 5: Achievements appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(AnimationConstants.elegantSpring) {
                showAchievements = true
            }
        }
        
        // Continuous subtle pulse for victory lap
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            victoryLapScale = 1.05
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
                .font(Theme.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(Theme.title2)
                .foregroundStyle(.white)
            
            Text(title)
                .font(Theme.caption)
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

