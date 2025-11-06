import SwiftUI

/// Agent 3: Motivational Quotes View - Displays motivational quotes during breaks
/// Provides encouraging and productivity-focused messages to help users maintain focus

struct MotivationalQuotesView: View {
    @State private var currentQuoteIndex: Int = 0
    @State private var fadeOpacity: Double = 1.0
    
    private let quotes: [MotivationalQuote] = [
        MotivationalQuote(
            text: "The way to get started is to quit talking and begin doing.",
            author: "Walt Disney"
        ),
        MotivationalQuote(
            text: "Focus on being productive instead of busy.",
            author: "Tim Ferriss"
        ),
        MotivationalQuote(
            text: "You don't have to be great to start, but you have to start to be great.",
            author: "Zig Ziglar"
        ),
        MotivationalQuote(
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs"
        ),
        MotivationalQuote(
            text: "Concentrate all your thoughts upon the work at hand. The sun's rays do not burn until brought to a focus.",
            author: "Alexander Graham Bell"
        ),
        MotivationalQuote(
            text: "Productivity is never an accident. It is always the result of a commitment to excellence.",
            author: "Paul J. Meyer"
        ),
        MotivationalQuote(
            text: "Focus on progress, not perfection.",
            author: "Unknown"
        ),
        MotivationalQuote(
            text: "The secret of getting ahead is getting started.",
            author: "Mark Twain"
        ),
        MotivationalQuote(
            text: "Time is the most valuable thing a man can spend.",
            author: "Theophrastus"
        ),
        MotivationalQuote(
            text: "Take a break, but don't break your momentum.",
            author: "Unknown"
        )
    ]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Quote icon
            Image(systemName: "quote.opening")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Theme.accentA.opacity(0.6))
            
            // Quote text
            Text(quotes[currentQuoteIndex].text)
                .font(Theme.title3)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(DesignSystem.Spacing.xs)
                .opacity(fadeOpacity)
                .animation(.easeInOut(duration: 0.5), value: fadeOpacity)
            
            // Author
            Text("— \(quotes[currentQuoteIndex].author)")
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
                .opacity(fadeOpacity)
                .animation(.easeInOut(duration: 0.5), value: fadeOpacity)
            
            // Dots indicator
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<min(5, quotes.count), id: \.self) { index in
                    Circle()
                        .fill(index == (currentQuoteIndex % 5) ? Theme.accentA : Theme.neutral300.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.accentA.opacity(0.3),
                                    Theme.accentB.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: DesignSystem.Border.standard
                        )
                )
        )
        .softShadow()
        .onAppear {
            // Cycle through quotes every 10 seconds
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                withAnimation {
                    fadeOpacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                    withAnimation {
                        fadeOpacity = 1.0
                    }
                }
            }
            
            // Start with random quote
            currentQuoteIndex = Int.random(in: 0..<quotes.count)
        }
    }
}

struct MotivationalQuote {
    let text: String
    let author: String
}

#Preview {
    MotivationalQuotesView()
        .padding()
        .background(ThemeBackground())
}

