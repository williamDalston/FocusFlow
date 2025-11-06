import SwiftUI

/// Agent 3: Pomodoro Cycle Progress View - Shows progress through Pomodoro cycle (1/4, 2/4, 3/4, 4/4)
/// Visual indicator of how many focus sessions have been completed in the current cycle

struct PomodoroCycleProgressView: View {
    let currentSession: Int // 1-4
    let totalSessions: Int = 4
    
    @State private var animatedProgress: Double = 0
    
    var progress: Double {
        Double(currentSession) / Double(totalSessions)
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.badge, style: .continuous)
                        .fill(Theme.neutral200.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.badge, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Theme.accentA, Theme.accentB],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: animatedProgress)
                }
            }
            .frame(height: 8)
            
            // Session indicators
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(1...totalSessions, id: \.self) { session in
                    Circle()
                        .fill(session <= currentSession ? Theme.accentA : Theme.neutral300.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(session == currentSession ? Theme.accentA : Color.clear, lineWidth: 2)
                                .scaleEffect(session == currentSession ? 1.5 : 1.0)
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentSession)
                }
            }
            
            // Text label
            Text("Session \(currentSession) of \(totalSessions)")
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), lineWidth: DesignSystem.Border.subtle)
                )
        )
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: currentSession) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        PomodoroCycleProgressView(currentSession: 1)
        PomodoroCycleProgressView(currentSession: 2)
        PomodoroCycleProgressView(currentSession: 3)
        PomodoroCycleProgressView(currentSession: 4)
    }
    .padding()
    .background(ThemeBackground())
}

