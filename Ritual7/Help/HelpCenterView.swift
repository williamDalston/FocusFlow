import SwiftUI

/// Agent 30: Enhanced Help Center with comprehensive help content and contextual guidance
struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var workoutStore: WorkoutStore
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
            
            let filtered = HelpContent.all.filter { content in
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
            
            ForEach(HelpContent.popular) { content in
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
                if let url = URL(string: "mailto:support@ritual7.app?subject=Help%20Request") {
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
    let content: HelpContent
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
    case workouts = "Workouts"
    case progress = "Progress"
    case settings = "Settings"
    
    var title: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .gettingStarted:
            return "play.circle.fill"
        case .workouts:
            return "figure.run"
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
        case .workouts:
            return Theme.accentB
        case .progress:
            return Theme.accentC
        case .settings:
            return .secondary
        }
    }
}

// MARK: - Help Content

struct HelpContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let category: HelpCategory
    
    static let all: [HelpContent] = [
        HelpContent(
            title: "How do I start my first workout?",
            description: "Learn how to begin your fitness journey",
            content: "Starting your first workout is easy! Simply tap the 'Start Workout' button on the main screen. Your workout will begin automatically with a short preparation countdown. You can customize your workout duration, rest periods, and exercises before starting.",
            category: .gettingStarted
        ),
        HelpContent(
            title: "How do I customize my workout?",
            description: "Adjust exercise duration, rest periods, and more",
            content: "To customize your workout, tap the 'Customize' button on the main screen. From there, you can adjust exercise duration (default 30 seconds), rest periods (default 10 seconds), and select which exercises to include. Changes are saved automatically.",
            category: .workouts
        ),
        HelpContent(
            title: "How does streak tracking work?",
            description: "Understand how your workout streak is calculated",
            content: "Your streak is the number of consecutive days you've completed a workout. Work out every day to keep your streak growing! If you miss a day, your streak resets to zero. The longer your streak, the more motivated you'll stay!",
            category: .progress
        ),
        HelpContent(
            title: "How do I pause or skip during a workout?",
            description: "Control your workout with pause, skip, and other options",
            content: "During a workout, you can pause by tapping the pause button or swiping right. You can skip rest periods by tapping the skip button or swiping left. You can also navigate between exercises using the previous/next buttons.",
            category: .workouts
        ),
        HelpContent(
            title: "How do I connect with Apple Health?",
            description: "Sync your workouts with Apple Health",
            content: "To connect with Apple Health, go to Settings > Health Integration and tap 'Connect with Health'. Grant the necessary permissions to sync your workouts, calories, and exercise minutes automatically. Your health data is private and secure.",
            category: .settings
        ),
        HelpContent(
            title: "How do I set up workout reminders?",
            description: "Get notified to complete your daily workout",
            content: "To set up reminders, go to Settings > Reminders & Notifications. Enable 'Daily Workout Reminder' and choose your preferred time. You can also enable streak reminders, gentle nudges, and weekly summaries.",
            category: .settings
        )
    ]
    
    static let popular: [HelpContent] = [
        all[0],
        all[1],
        all[2],
        all[3]
    ]
}

