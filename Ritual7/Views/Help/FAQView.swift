import SwiftUI

/// Agent 6: FAQ View - Frequently asked questions
struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedIndex: Int? = nil
    
    let faqs: [FAQ] = [
        FAQ(
            question: "How long is each workout?",
            answer: "Each workout is approximately 7 minutes long. You'll complete 12 exercises, each lasting 30 seconds with 10-second rest periods between exercises."
        ),
        FAQ(
            question: "Do I need any equipment?",
            answer: "You only need a sturdy chair for some exercises like the wall sit, triceps dip, and step-up. Everything else can be done with just your body weight."
        ),
        FAQ(
            question: "How many times should I do this workout?",
            answer: "The workout is designed to be done daily. You can do it once a day or repeat it multiple times if you want a longer workout. Listen to your body and rest when needed."
        ),
        FAQ(
            question: "Can beginners do this workout?",
            answer: "Yes! The workout can be modified for all fitness levels. Each exercise guide includes modifications for beginners, intermediate, and advanced levels. Start at your own pace and gradually increase intensity."
        ),
        FAQ(
            question: "What if I can't complete an exercise?",
            answer: "That's perfectly fine! Use the modifications provided in the exercise guide, or simply rest during that exercise. The goal is to do your best and gradually improve over time."
        ),
        FAQ(
            question: "Can I pause the workout?",
            answer: "Yes, you can pause the workout at any time by tapping the pause button. The timer will stop and wait for you to resume when you're ready."
        ),
        FAQ(
            question: "How do I track my progress?",
            answer: "The app automatically tracks your workouts, streaks, and statistics. You can view your progress in the History tab and see your workout statistics on the main screen."
        ),
        FAQ(
            question: "Is this workout safe for everyone?",
            answer: "If you have any health concerns or medical conditions, please consult with a healthcare provider before starting any exercise program. Always listen to your body and stop if you experience pain."
        ),
        FAQ(
            question: "Can I customize the workout?",
            answer: "The workout follows a proven 12-exercise sequence, but you can modify individual exercises based on your fitness level. Check the exercise guide for modification options."
        ),
        FAQ(
            question: "Does the app work offline?",
            answer: "Yes! Once downloaded, the app works completely offline. You don't need an internet connection to use the workout timer or view your progress."
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
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
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
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.accentA)
                        .padding(.top, 4)
                }
                .padding(20)
                
                // Answer (expanded)
                if isExpanded {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    Text(faq.answer)
                        .font(.body)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isExpanded ? Theme.accentA : Theme.strokeOuter, lineWidth: isExpanded ? 1.5 : 0.8)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


