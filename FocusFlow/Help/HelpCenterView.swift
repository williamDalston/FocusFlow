import SwiftUI

/// Agent 7: Enhanced Help Center with comprehensive help content and contextual guidance for Pomodoro Timer app
struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Search bar
                        searchBar
                        
                        // Quick help categories
                        if searchText.isEmpty {
                            quickHelpCategories
                        } else {
                            searchResults
                        }
                        
                        // Popular questions
                        if searchText.isEmpty {
                            popularQuestions
                        }
                        
                        // Contact support
                        contactSupport
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.formFieldSpacing)
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Haptics.tap()
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentA)
                }
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search for help...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Quick Help Categories
    
    private var quickHelpCategories: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Help")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(HelpCategory.allCases, id: \.self) { category in
                    HelpCategoryCard(category: category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - Search Results
    
    private var searchResults: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Search Results")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            let filtered = HelpCenterContent.all.filter { content in
                content.title.localizedCaseInsensitiveContains(searchText) ||
                content.description.localizedCaseInsensitiveContains(searchText) ||
                content.content.localizedCaseInsensitiveContains(searchText)
            }
            
            if filtered.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Results",
                    message: "We couldn't find anything matching \"\(searchText)\". Try different keywords or browse categories below.",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                ForEach(filtered) { content in
                    HelpContentCard(content: content)
                }
            }
        }
    }
    
    // MARK: - Popular Questions
    
    private var popularQuestions: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Popular Questions")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            ForEach(HelpCenterContent.popular) { content in
                HelpContentCard(content: content)
            }
        }
    }
    
    // MARK: - Contact Support
    
    private var contactSupport: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Still Need Help?")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)
            
            Text("Can't find what you're looking for? Contact our support team.")
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                // Open support email or contact form
                if let url = URL(string: "mailto:support@pomodorotimer.app?subject=Pomodoro%20Timer%20Help%20Request") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Contact Support", systemImage: "envelope.fill")
                    .font(Theme.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.ButtonSize.standard.height)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
        }
        .padding(DesignSystem.Spacing.formFieldSpacing)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Help Category Card

private struct HelpCategoryCard: View {
    let category: HelpCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.system(size: DesignSystem.IconSize.xlarge, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [category.color, category.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(category.title)
                    .font(Theme.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Help Content Card

private struct HelpContentCard: View {
    let content: HelpCenterContent
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
                Haptics.tap()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(content.title)
                            .font(Theme.headline)
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        if !isExpanded {
                            Text(content.description)
                                .font(Theme.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(Theme.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(content.content)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Help Category

enum HelpCategory: String, CaseIterable {
    case gettingStarted = "Getting Started"
    case focusSessions = "Focus Sessions"
    case progress = "Progress"
    case settings = "Settings"
    
    var title: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .gettingStarted:
            return "play.circle.fill"
        case .focusSessions:
            return "brain.head.profile"
        case .progress:
            return "chart.bar.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .gettingStarted:
            return Theme.accentA
        case .focusSessions:
            return Theme.accentB
        case .progress:
            return Theme.accentC
        case .settings:
            return .secondary
        }
    }
}

// MARK: - Help Center Content

struct HelpCenterContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let category: HelpCategory
    
    static let all: [HelpCenterContent] = [
        HelpCenterContent(
            title: "How do I start my first focus session?",
            description: "Learn how to begin using the Pomodoro Technique",
            content: "Starting your first focus session is easy! Simply tap the 'Start Focus' button on the main screen. Your timer will begin automatically with a 25-minute focus session. You can customize your timer presets and durations in Settings before starting.",
            category: .gettingStarted
        ),
        HelpCenterContent(
            title: "What is the Pomodoro Technique?",
            description: "Learn about the Pomodoro Technique",
            content: "The Pomodoro Technique is a time management method that uses a timer to break work into intervals. You work in focused 25-minute sessions, take 5-minute breaks, and enjoy a 15-minute long break after every 4 sessions. This proven method helps maintain concentration and avoid burnout. Tap the Pomodoro Guide in Settings to learn more.",
            category: .gettingStarted
        ),
        HelpCenterContent(
            title: "How do I customize my timer?",
            description: "Adjust focus duration, break duration, and presets",
            content: "To customize your timer, go to Settings > Timer Settings. From there, you can adjust focus duration (default 25 minutes), short break duration (default 5 minutes), and long break duration (default 15 minutes). You can also select from preset configurations like Classic, Deep Work, or Short Sprints. Changes are saved automatically.",
            category: .focusSessions
        ),
        HelpCenterContent(
            title: "How does streak tracking work?",
            description: "Understand how your focus streak is calculated",
            content: "Your streak is the number of consecutive days you've completed at least one focus session. Complete sessions daily to keep your streak growing! If you miss a day, your streak resets to zero. The longer your streak, the more motivated you'll stay and the stronger your productivity habit becomes.",
            category: .progress
        ),
        HelpCenterContent(
            title: "How do I pause during a focus session?",
            description: "Control your timer with pause and resume",
            content: "During a focus session, you can pause by tapping the pause button. You can resume anytime by tapping the resume button. The timer will continue from where you left off. Note: Pausing doesn't count as a break - make sure to take your scheduled breaks to maintain the Pomodoro rhythm.",
            category: .focusSessions
        ),
        HelpCenterContent(
            title: "What happens after 4 sessions?",
            description: "Understanding Pomodoro cycles and long breaks",
            content: "After completing 4 focus sessions (with short breaks in between), you'll automatically get a 15-minute long break. This is part of the Pomodoro cycle designed to give your brain a longer recovery period. The cycle then resets, and you can start a new set of 4 sessions.",
            category: .focusSessions
        ),
        HelpCenterContent(
            title: "How do I set up focus reminders?",
            description: "Get notified to start your daily focus sessions",
            content: "To set up reminders, go to Settings > Reminders & Notifications. Enable 'Daily Focus Reminder' and choose your preferred time. You can also enable streak reminders and weekly progress summaries. Notifications help you build a consistent focus habit.",
            category: .settings
        ),
        HelpCenterContent(
            title: "How do I view my focus statistics?",
            description: "Track your progress and productivity",
            content: "View your focus statistics by tapping the 'History' or 'Statistics' button on the main screen. You'll see your daily focus time, completed sessions, current streak, and weekly/monthly trends. This helps you understand your productivity patterns and stay motivated.",
            category: .progress
        )
    ]
    
    static let popular: [HelpCenterContent] = [
        all[0],
        all[1],
        all[2],
        all[3]
    ]
}

