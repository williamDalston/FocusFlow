import SwiftUI

/// Agent 7: Daily motivational quote view
struct DailyQuoteView: View {
    @StateObject private var messageManager = MotivationalMessageManager.shared
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    // Icon with rounded background and depth
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.accentA.opacity(DesignSystem.Opacity.light * 1.25),
                                        Theme.accentB.opacity(DesignSystem.Opacity.light),
                                        Theme.accentC.opacity(DesignSystem.Opacity.subtle * 1.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: DesignSystem.TouchTarget.minimum, height: DesignSystem.TouchTarget.minimum)
                            .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium), 
                                   radius: DesignSystem.Shadow.small.radius, 
                                   y: DesignSystem.Shadow.small.y)
                            .shadow(color: Theme.glowColor.opacity(DesignSystem.Opacity.subtle), 
                                   radius: DesignSystem.Shadow.verySoft.radius, 
                                   y: DesignSystem.Shadow.verySoft.y)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Theme.accentA.opacity(DesignSystem.Opacity.medium * 1.3),
                                                Theme.accentB.opacity(DesignSystem.Opacity.light * 1.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: DesignSystem.Border.standard
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                    .stroke(
                                        Theme.glowColor.opacity(DesignSystem.Opacity.glow),
                                        lineWidth: DesignSystem.Border.hairline
                                    )
                                    .blur(radius: 1)
                            )
                        
                        Image(systemName: "quote.opening")
                            .font(Theme.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accentA, Theme.accentB],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("Daily Motivation")
                        .font(Theme.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.textPrimary, Theme.textPrimary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.83), radius: DesignSystem.Shadow.verySoft.radius * 0.17, x: 0, y: DesignSystem.Shadow.verySoft.y * 0.17)
                    
                    Spacer()
                }
                
                Text(messageManager.dailyQuote)
                    .font(Theme.body.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(DesignSystem.Spacing.xs)
                        .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.42), radius: DesignSystem.Shadow.verySoft.radius * 0.08, x: 0, y: DesignSystem.Shadow.verySoft.y * 0.08)
                
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.5))
                            .frame(width: DesignSystem.IconSize.xlarge, height: DesignSystem.IconSize.xlarge)
                            .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.subtle), 
                                   radius: DesignSystem.Shadow.verySoft.radius, 
                                   y: DesignSystem.Shadow.verySoft.y)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                    .stroke(Theme.accentA.opacity(DesignSystem.Opacity.light * 1.5), lineWidth: DesignSystem.Border.standard)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                    .stroke(Theme.glowColor.opacity(DesignSystem.Opacity.glow * 0.8), lineWidth: DesignSystem.Border.hairline)
                                    .blur(radius: 0.5)
                            )
                        
                        Image(systemName: "quote.closing")
                            .font(Theme.caption.weight(.semibold))
                            .foregroundStyle(Theme.accentA)
                    }
                }
            }
            .padding(DesignSystem.Spacing.formFieldSpacing)
        }
        .onAppear {
            messageManager.loadDailyQuote()
        }
    }
}

/// Streak celebration view with fire animation
struct StreakCelebrationView: View {
    let streak: Int
    @State private var showFire = false
    @State private var pulseAnimation = false
    @State private var previousStreak = 0
    
    // Check if this is a milestone (7, 14, 30, 50, 100 days)
    private var isMilestone: Bool {
        [7, 14, 30, 50, 100].contains(streak)
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Flame icon with rounded background and depth - larger and more prominent
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(DesignSystem.Opacity.medium * 1.5),
                                    Color.orange.opacity(DesignSystem.Opacity.light * 1.25),
                                    Color.orange.opacity(DesignSystem.Opacity.light)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: DesignSystem.IconSize.huge, height: DesignSystem.IconSize.huge)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .shadow(color: Color.orange.opacity(DesignSystem.Opacity.medium * 1.3), 
                               radius: DesignSystem.Shadow.medium.radius, 
                               y: DesignSystem.Shadow.medium.y)
                        .shadow(color: Color.orange.opacity(DesignSystem.Opacity.light), 
                               radius: DesignSystem.Shadow.small.radius, 
                               y: DesignSystem.Shadow.small.y)
                        .shadow(color: Color.orange.opacity(DesignSystem.Opacity.glow * 1.2), 
                               radius: DesignSystem.Shadow.verySoft.radius, 
                               y: DesignSystem.Shadow.verySoft.y)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(DesignSystem.Opacity.strong),
                                            Color.orange.opacity(DesignSystem.Opacity.medium * 1.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: DesignSystem.Border.emphasis
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                                .stroke(Color.white.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.hairline)
                                .blur(radius: 1)
                        )
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: DesignSystem.IconSize.xxlarge, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(showFire ? 1.15 : 1.0)
                        .shadow(color: Color.orange.opacity(DesignSystem.Opacity.strong), radius: DesignSystem.Shadow.verySoft.radius * 0.33, x: 0, y: DesignSystem.Shadow.verySoft.y * 0.33)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    // Larger, bolder streak number with pulse animation - Enhanced with stronger shadow
                    Text("\(streak)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: isMilestone ? [Color.orange, Color.orange.opacity(0.9)] : [Theme.textPrimary, Theme.textPrimary.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .monospacedDigit()
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 1.5), 
                               radius: DesignSystem.Shadow.verySoft.radius * 0.5, 
                               x: 0, y: DesignSystem.Shadow.verySoft.y * 0.25)
                        .contentTransition(.numericText())
                    
                    Text("day streak")
                        .font(Theme.headline.weight(.bold))
                        .foregroundStyle(.secondary)
                        .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 1.0), 
                               radius: DesignSystem.Shadow.verySoft.radius * 0.3, 
                               x: 0, y: DesignSystem.Shadow.verySoft.y * 0.2)
                }
                
                Spacer()
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true), value: showFire)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: pulseAnimation)
            
            // Enhanced milestone celebration
            if isMilestone {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: DesignSystem.IconSize.small, weight: .bold))
                        .foregroundStyle(Color.orange)
                    Text("Milestone Achieved!")
                        .font(Theme.subheadline.weight(.bold))
                        .foregroundStyle(Color.orange)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .fill(Color.orange.opacity(DesignSystem.Opacity.highlight))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .stroke(Color.orange.opacity(DesignSystem.Opacity.medium), lineWidth: DesignSystem.Border.standard)
                        )
                        .shadow(color: Color.orange.opacity(DesignSystem.Opacity.subtle), 
                               radius: DesignSystem.Shadow.verySoft.radius, 
                               y: DesignSystem.Shadow.verySoft.y)
                )
                .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                .transition(.scale.combined(with: .opacity))
            } else if streak >= 7 {
                Text(Quotes.forStreak(streak))
                    .font(Theme.caption.weight(.medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs + 2)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.0))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                    .stroke(Theme.accentA.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
                            )
                            .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.subtle), 
                                   radius: DesignSystem.Shadow.verySoft.radius, 
                                   y: DesignSystem.Shadow.verySoft.y)
                    )
            }
        }
        .onAppear {
            showFire = true
            previousStreak = streak
        }
        .onChange(of: streak) { newStreak in
            // Pulse animation when streak updates
            if newStreak > previousStreak {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    pulseAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        pulseAnimation = false
                    }
                }
                previousStreak = newStreak
            }
        }
    }
}

/// Agent 21: Achievement celebration view - Enhanced and more prominent
struct AchievementCelebrationView: View {
    let achievement: AchievementNotifier.Achievement
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.8
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss
    
    // Agent 21: Get achievement color from icon mapping
    private var achievementColor: Color {
        // Map common achievement icons to colors
        if achievement.icon.contains("flame") { return .orange }
        if achievement.icon.contains("trophy") { return .purple }
        if achievement.icon.contains("crown") { return .yellow }
        if achievement.icon.contains("star") { return .yellow }
        if achievement.icon.contains("medal") { return .blue }
        return Theme.accentA
    }
    
    var body: some View {
        ZStack {
            // Agent 21: Enhanced background with gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    achievementColor.opacity(0.15),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Agent 21: Multiple confetti bursts
            if showConfetti {
                ConfettiView(trigger: $showConfetti)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer()
                
                // Agent 21: Large icon with glow and pulse animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    achievementColor.opacity(glowOpacity * 0.6),
                                    achievementColor.opacity(glowOpacity * 0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Pulsing background circle
                    Circle()
                        .fill(achievementColor.opacity(0.2))
                        .frame(width: 120 * pulseScale, height: 120 * pulseScale)
                    
                    // Icon with rotation
                    Image(systemName: achievement.icon)
                        .font(.system(size: DesignSystem.IconSize.huge * 1.5, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [achievementColor, achievementColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: achievementColor.opacity(0.8), radius: 20, x: 0, y: 0)
                }
                
                // Agent 21: Enhanced title and message
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Achievement Unlocked!")
                        .font(Theme.footnote.smallCaps())
                        .foregroundStyle(.secondary)
                        .tracking(DesignSystem.Typography.uppercaseTracking)
                    
                    Text(achievement.title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .shadow(color: Theme.shadow.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text(achievement.message)
                        .font(Theme.title3)
                        .foregroundStyle(achievementColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                Spacer()
                
                // Agent 21: Dismiss button
                Button {
                    Haptics.success()
                    dismiss()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Awesome!")
                            .fontWeight(.bold)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.ButtonSize.large.height)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xl)
                .accessibilityLabel("Dismiss achievement celebration")
            }
        }
        .onAppear {
            // Agent 21: Enhanced entrance animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                glowOpacity = 1.0
            }
            
            // Confetti after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showConfetti = true
                Haptics.success()
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
            
            // Rotation animation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

/// Motivational message card
struct MotivationalMessageCard: View {
    let message: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(material: .ultraThinMaterial) {
            HStack(spacing: 14) {
                // Icon with rounded background and depth
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(DesignSystem.Opacity.light * 1.25),
                                    color.opacity(DesignSystem.Opacity.light),
                                    color.opacity(DesignSystem.Opacity.subtle * 1.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: DesignSystem.IconSize.xxlarge, height: DesignSystem.IconSize.xxlarge)
                        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.medium), 
                               radius: DesignSystem.Shadow.medium.radius, 
                               y: DesignSystem.Shadow.medium.y)
                        .shadow(color: color.opacity(DesignSystem.Opacity.glow * 1.2), 
                               radius: DesignSystem.Shadow.soft.radius, 
                               y: DesignSystem.Shadow.soft.y)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            color.opacity(DesignSystem.Opacity.medium * 1.3),
                                            color.opacity(DesignSystem.Opacity.light * 1.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: DesignSystem.Border.standard
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .stroke(Color.white.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.hairline)
                                .blur(radius: 0.5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                                .stroke(color.opacity(DesignSystem.Opacity.glow), lineWidth: DesignSystem.Border.hairline)
                                .blur(radius: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(Theme.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: color.opacity(DesignSystem.Opacity.medium), radius: DesignSystem.Shadow.verySoft.radius * 0.17, x: 0, y: DesignSystem.Shadow.verySoft.y * 0.17)
                }
                
                Text(message)
                    .font(Theme.body.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: Theme.shadow.opacity(DesignSystem.Opacity.subtle * 0.67), radius: DesignSystem.Shadow.verySoft.radius * 0.125, x: 0, y: DesignSystem.Shadow.verySoft.y * 0.08)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}


