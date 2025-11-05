import SwiftUI

/// Agent 7: Daily motivational quote view
struct DailyQuoteView: View {
    @StateObject private var messageManager = MotivationalMessageManager.shared
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        GlassCard(material: .ultraThinMaterial) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.title3)
                        .foregroundStyle(Theme.accentA)
                    
                    Text("Daily Motivation")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Spacer()
                }
                
                Text(messageManager.dailyQuote)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Image(systemName: "quote.closing")
                        .font(.caption)
                        .foregroundStyle(Theme.accentA.opacity(0.6))
                }
            }
            .padding(20)
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
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .scaleEffect(showFire ? 1.2 : 1.0)
                
                Text("\(streak)")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("day streak")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showFire)
            
            if streak >= 7 {
                Text(Quotes.forStreak(streak))
                    .font(.caption)
                    .foregroundStyle(Theme.accentA)
                    .multilineTextAlignment(.center)
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
                .padding(24)
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(16)
        }
    }
}


