import SwiftUI

// MARK: - Help Context

enum HelpContext: String, Identifiable {
    case workoutCustomization
    case workoutHistory
    case streakTracking
    case achievements
    case settings
    case healthIntegration
    case gestureControls
    
    var id: String {
        rawValue
    }
}

// MARK: - Help Content

struct HelpContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let icon: String
    let color: Color
}

/// Agent 30: Contextual help manager that provides helpful hints and tooltips throughout the app
/// Shows contextual help based on user actions and screen context
class ContextualHelpManager: ObservableObject {
    static let shared = ContextualHelpManager()
    
    @Published var showHelpOverlay = false
    @Published var currentHelpContext: HelpContext? = nil
    @Published var dismissedHints: Set<String> = []
    
    private init() {
        loadDismissedHints()
    }
    
    // MARK: - Help Overlay Management
    
    /// Show help overlay for a specific context
    func showHelp(for context: HelpContext) {
        currentHelpContext = context
        showHelpOverlay = true
    }
    
    /// Dismiss help overlay
    func dismissHelp() {
        showHelpOverlay = false
        if let context = currentHelpContext {
            markHintAsDismissed(context.id)
        }
        currentHelpContext = nil
    }
    
    /// Check if help should be shown for a context (first time only)
    func shouldShowHelp(for context: HelpContext) -> Bool {
        !dismissedHints.contains(context.id)
    }
    
    /// Mark a hint as dismissed (so it won't show again)
    func markHintAsDismissed(_ hintId: String) {
        dismissedHints.insert(hintId)
        saveDismissedHints()
    }
    
    /// Reset all dismissed hints (useful for testing or onboarding)
    func resetDismissedHints() {
        dismissedHints.removeAll()
        saveDismissedHints()
    }
    
    // MARK: - Contextual Help Content
    
    /// Get help content for a specific context
    func helpContent(for context: HelpContext) -> HelpContent {
        switch context {
        case .workoutCustomization:
            return HelpContent(
                title: "Customize Your Workout",
                description: "Adjust exercise duration, rest periods, and select exercises",
                content: "Use the customization screen to tailor your workout to your preferences. You can adjust how long each exercise lasts (default: 30 seconds), how long rest periods are (default: 10 seconds), and choose which exercises to include. Your preferences are saved automatically.",
                icon: "slider.horizontal.3",
                color: Theme.accentA
            )
        case .workoutHistory:
            return HelpContent(
                title: "View Your Progress",
                description: "See all your past workouts and track your statistics",
                content: "Your workout history shows all completed sessions with dates, durations, and exercises completed. Swipe left on any workout to delete it, or tap to view details. Use the search and filter options to find specific workouts.",
                icon: "clock.fill",
                color: Theme.accentB
            )
        case .streakTracking:
            return HelpContent(
                title: "Build Your Streak",
                description: "Work out every day to keep your streak growing",
                content: "Your streak is the number of consecutive days you've completed a workout. Work out every day to keep it growing! The longer your streak, the more motivated you'll stay. If you miss a day, your streak resets—but don't worry, you can always start a new one!",
                icon: "flame.fill",
                color: Theme.accentC
            )
        case .achievements:
            return HelpContent(
                title: "Unlock Achievements",
                description: "Complete workouts to earn badges and milestones",
                content: "Achievements are unlocked by completing workouts and reaching milestones like first workout, week streak, or 100 workouts. Check back regularly to see your progress and celebrate your accomplishments!",
                icon: "trophy.fill",
                color: Theme.accentA
            )
        case .settings:
            return HelpContent(
                title: "Configure Settings",
                description: "Customize appearance, notifications, and app preferences",
                content: "In Settings, you can customize your app experience. Change color themes, adjust sound and haptic settings, set up workout reminders, connect with Apple Health, and more. All changes are saved automatically.",
                icon: "gearshape.fill",
                color: .secondary
            )
        case .healthIntegration:
            return HelpContent(
                title: "Connect with Apple Health",
                description: "Sync your workouts with Apple Health automatically",
                content: "Connecting with Apple Health allows your workouts to sync automatically with the Health app. Your workout sessions, calories burned, and exercise minutes will be tracked. Your health data is private and secure—only you can see it.",
                icon: "heart.text.square.fill",
                color: Theme.accentB
            )
        case .gestureControls:
            return HelpContent(
                title: "Gesture Controls",
                description: "Use swipe gestures to control your workout",
                content: "During workouts, you can use gestures for quick control. Swipe right to pause or resume, swipe left to skip rest periods. These gestures make it easy to control your workout without looking at the screen.",
                icon: "hand.draw.fill",
                color: Theme.accentC
            )
        }
    }
    
    // MARK: - Persistence
    
    private func saveDismissedHints() {
        UserDefaults.standard.set(Array(dismissedHints), forKey: "dismissedHelpHints")
    }
    
    private func loadDismissedHints() {
        if let saved = UserDefaults.standard.array(forKey: "dismissedHelpHints") as? [String] {
            dismissedHints = Set(saved)
        }
    }
}

// MARK: - Contextual Help Overlay View

struct ContextualHelpOverlay: View {
    @ObservedObject var manager = ContextualHelpManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if manager.showHelpOverlay, let context = manager.currentHelpContext {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        manager.dismissHelp()
                    }
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Icon
                    Image(systemName: manager.helpContent(for: context).icon)
                        .font(.system(size: DesignSystem.IconSize.huge, weight: DesignSystem.IconWeight.standard))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [manager.helpContent(for: context).color, manager.helpContent(for: context).color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Title
                    Text(manager.helpContent(for: context).title)
                        .font(Theme.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    // Description
                    Text(manager.helpContent(for: context).description)
                        .font(Theme.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Content
                    Text(manager.helpContent(for: context).content)
                        .font(Theme.body)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Dismiss button
                    Button {
                        manager.dismissHelp()
                    } label: {
                        Text("Got it")
                            .font(Theme.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.ButtonSize.standard.height)
                    }
                    .buttonStyle(PrimaryProminentButtonStyle())
                    .padding(.top, DesignSystem.Spacing.md)
                }
                .padding(DesignSystem.Spacing.formFieldSpacing)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                )
                .padding(DesignSystem.Spacing.xl)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

