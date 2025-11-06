import SwiftUI

/// Agent 6: FAQ View - Frequently asked questions
struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedIndex: Int? = nil
    
    let faqs: [FAQ] = [
        FAQ(
            question: "How long is each focus session?",
            answer: "Focus sessions can be customized, but the classic Pomodoro timer is 25 minutes of focused work followed by a 5-minute break. You can also use presets like Deep Work (45 minutes) or Quick Focus (15 minutes)."
        ),
        FAQ(
            question: "What is the Pomodoro Technique?",
            answer: "The Pomodoro Technique is a time management method that breaks work into focused intervals (typically 25 minutes) followed by short breaks. After 4 focus sessions, you take a longer break."
        ),
        FAQ(
            question: "How many focus sessions should I do per day?",
            answer: "Focus sessions can be done throughout the day as needed. The app tracks your sessions and helps you maintain consistency. Listen to your mind and take breaks when needed."
        ),
        FAQ(
            question: "Can I customize the timer intervals?",
            answer: "Yes! The app includes several presets (Classic Pomodoro, Deep Work, Quick Focus) and you can customize the focus duration, short break, and long break times to match your preferences."
        ),
        FAQ(
            question: "What if I get interrupted during a focus session?",
            answer: "You can pause the focus session at any time by tapping the pause button. The timer will stop and wait for you to resume when you're ready."
        ),
        FAQ(
            question: "Can I pause the timer?",
            answer: "Yes, you can pause the timer at any time by tapping the pause button. The timer will stop and wait for you to resume when you're ready."
        ),
        FAQ(
            question: "How do I track my progress?",
            answer: "The app automatically tracks your focus sessions, streaks, and statistics. You can view your progress in the History tab and see your focus statistics on the main screen."
        ),
        FAQ(
            question: "Is this app suitable for everyone?",
            answer: "Yes! The Pomodoro Technique is a proven method for improving focus and productivity. Whether you're studying, working, or doing creative work, this app can help you stay focused."
        ),
        FAQ(
            question: "Can I customize the Pomodoro settings?",
            answer: "Yes! You can customize the focus duration, break durations, and cycle length. Check the Settings tab to customize your Pomodoro timer preferences."
        ),
        FAQ(
            question: "Does the app work offline?",
            answer: "Yes! Once downloaded, the app works completely offline. You don't need an internet connection to use the timer or view your progress."
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(faqs.enumerated()), id: \.offset) { offset, faq in
                            FAQCard(
                                faq: faq,
                                isExpanded: expandedIndex == offset,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        expandedIndex = expandedIndex == offset ? nil : offset
                                    }
                                    Haptics.tap()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.formFieldSpacing)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
            .navigationTitle("Frequently Asked Questions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentA)
                }
            }
        }
    }
}

struct FAQ {
    let question: String
    let answer: String
}

struct FAQCard: View {
    let faq: FAQ
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Question
                HStack(alignment: .top, spacing: 16) {
                    Text(faq.question)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(Theme.caption.weight(.semibold))
                        .foregroundStyle(Theme.accentA)
                        .padding(.top, DesignSystem.Spacing.xs)
                }
                .padding(DesignSystem.Spacing.formFieldSpacing)
                
                // Answer (expanded)
                if isExpanded {
                    Divider()
                        .padding(.horizontal, DesignSystem.Spacing.formFieldSpacing)
                    
                    Text(faq.answer)
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(DesignSystem.Spacing.formFieldSpacing)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                            .stroke(isExpanded ? Theme.accentA : Theme.strokeOuter, lineWidth: isExpanded ? DesignSystem.Border.emphasis : DesignSystem.Border.subtle)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


