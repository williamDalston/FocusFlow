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
                            .frame(width: 44, height: 44)
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
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accentA, Theme.accentB],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("Daily Motivation")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.textPrimary, Theme.textPrimary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Theme.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                
                Text(messageManager.dailyQuote)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .shadow(color: Theme.shadow.opacity(0.05), radius: 1, x: 0, y: 0.5)
                
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                            .fill(Theme.accentA.opacity(DesignSystem.Opacity.subtle * 1.5))
                            .frame(width: 32, height: 32)
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
                            .font(.caption.weight(.semibold))
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
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Flame icon with rounded background and depth
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
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
                        .frame(width: 52, height: 52)
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
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
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
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .stroke(Color.white.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.hairline)
                                .blur(radius: 1)
                        )
                    
                    Image(systemName: "flame.fill")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(showFire ? 1.15 : 1.0)
                        .shadow(color: Color.orange.opacity(0.5), radius: 4, x: 0, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(streak)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.textPrimary, Theme.textPrimary.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .monospacedDigit()
                        .shadow(color: Theme.shadow.opacity(0.15), radius: 3, x: 0, y: 1)
                    
                    Text("day streak")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .shadow(color: Theme.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true), value: showFire)
            
            if streak >= 7 {
                Text(Quotes.forStreak(streak))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentA, Theme.accentB],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
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
        }
    }
}

/// Achievement celebration view
struct AchievementCelebrationView: View {
    let achievement: AchievementNotifier.Achievement
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if showConfetti {
                    ConfettiView(trigger: $showConfetti)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack(spacing: 12) {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.accentA)
                        .scaleEffect(scale)
                    
                    Text(achievement.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text(achievement.message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(DesignSystem.Spacing.cardPadding)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showConfetti = true
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
                        .frame(width: 48, height: 48)
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
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                Text(message)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: Theme.shadow.opacity(0.08), radius: 1.5, x: 0, y: 0.5)
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}


