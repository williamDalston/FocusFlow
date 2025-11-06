import SwiftUI

/// Agent 3: Session Complete View - Celebration screen for completed focus sessions
/// Replaces CompletionCelebrationView with focus/productivity theme
/// Provides a rewarding experience after completing a focus session

struct FocusSessionCompletionStats {
    let duration: TimeInterval
    let phaseType: FocusPhase
    let cycleNumber: Int?
    let currentStreak: Int
    let isStreakDay: Bool
    let isPersonalBest: Bool
    let totalFocusTimeToday: TimeInterval
    let unlockedAchievements: [String]
}

struct SessionCompleteView: View {
    let sessionStats: FocusSessionCompletionStats
    let onDismiss: () -> Void
    let onStartNew: () -> Void
    
    @State private var showStats = false
    @State private var showAchievements = false
    @State private var animationPhase: Int = 0
    @State private var confettiTrigger = false
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var checkmarkRotation: Double = 0
    
    var formattedDuration: String {
        let minutes = Int(sessionStats.duration) / 60
        let seconds = Int(sessionStats.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Theme.bgDeep.opacity(0.95),
                    Theme.bgDeep.opacity(0.90),
                    sessionStats.phaseType.color.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Confetti celebration (using existing ConfettiView from UI package)
            ConfettiView(trigger: $confettiTrigger)
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Celebration header
                    celebrationHeader
                        .scaleEffect(checkmarkScale)
                        .rotationEffect(.degrees(checkmarkRotation))
                    
                    // Stats grid
                    if showStats {
                        statsGrid
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Achievement unlocks
                    if showAchievements && !sessionStats.unlockedAchievements.isEmpty {
                        achievementsSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Motivational quote during breaks
                    if sessionStats.phaseType != .focus {
                        MotivationalQuotesView()
                            .padding(.top, DesignSystem.Spacing.md)
                    }
                    
                    // Action buttons
                    actionButtons
                }
                .padding(DesignSystem.Spacing.xl)
            }
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    // MARK: - Celebration Header
    
    private var celebrationHeader: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Checkmark circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                sessionStats.phaseType.color.opacity(0.3),
                                sessionStats.phaseType.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                sessionStats.phaseType.color.opacity(0.5),
                                lineWidth: 3
                            )
                    )
                
                if animationPhase >= 2 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(sessionStats.phaseType.color)
                }
            }
            
            // Success message
            if animationPhase >= 3 {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Session Complete!")
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("Great job staying focused")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.md) {
            FocusStatCard(
                title: "Duration",
                value: formattedDuration,
                icon: "clock.fill",
                color: Theme.accentA
            )
            
            FocusStatCard(
                title: "Streak",
                value: "\(sessionStats.currentStreak) days",
                icon: "flame.fill",
                color: Theme.accentB
            )
            
            FocusStatCard(
                title: "Today",
                value: formatTime(sessionStats.totalFocusTimeToday),
                icon: "calendar",
                color: Theme.accentC
            )
            
            if sessionStats.isPersonalBest {
                FocusStatCard(
                    title: "Personal Best!",
                    value: "🎉",
                    icon: "star.fill",
                    color: Theme.accentB
                )
            }
        }
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Achievements Unlocked")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            ForEach(sessionStats.unlockedAchievements, id: \.self) { achievement in
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "trophy.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accentB)
                    
                    Text(achievement)
                        .font(Theme.body)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .stroke(Theme.accentB.opacity(0.3), lineWidth: DesignSystem.Border.standard)
                )
        )
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button(action: onStartNew) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("Start Next Session")
                        .font(Theme.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button, style: .continuous)
                        .fill(Theme.accentA)
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            Button(action: onDismiss) {
                Text("Done")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    private func startCelebrationAnimation() {
        // Initial confetti burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            confettiTrigger = true
            Haptics.success()
        }
        
        // Phase 1: Circle appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animationPhase = 1
                checkmarkScale = 1.0
            }
        }
        
        // Phase 2: Checkmark appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                animationPhase = 2
                checkmarkRotation = 360
            }
        }
        
        // Phase 3: Text appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                animationPhase = 3
            }
        }
        
        // Phase 4: Stats appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showStats = true
            }
        }
        
        // Phase 5: Achievements appear
        if !sessionStats.unlockedAchievements.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAchievements = true
                }
            }
        }
    }
}

// MARK: - Focus Stat Card

private struct FocusStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(Theme.title3)
                .foregroundStyle(Theme.textPrimary)
            
            Text(title)
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: DesignSystem.Border.subtle)
                )
        )
    }
}


#Preview {
    SessionCompleteView(
        sessionStats: FocusSessionCompletionStats(
            duration: 1500,
            phaseType: .focus,
            cycleNumber: 2,
            currentStreak: 5,
            isStreakDay: true,
            isPersonalBest: false,
            totalFocusTimeToday: 3600,
            unlockedAchievements: ["First Session", "5 Day Streak"]
        ),
        onDismiss: {},
        onStartNew: {}
    )
}

