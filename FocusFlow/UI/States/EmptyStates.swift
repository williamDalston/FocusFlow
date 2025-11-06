import SwiftUI

// MARK: - Enhanced Empty State Components

/// Agent 7: Enhanced empty state view with better messaging and visuals
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @State private var isVisible = false
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Enhanced icon with refined animation and glow
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.huge * 1.2, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Theme.accentA.opacity(DesignSystem.Opacity.strong),
                            Theme.accentB.opacity(DesignSystem.Opacity.medium),
                            Theme.accentC.opacity(DesignSystem.Opacity.medium)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .shadow(color: Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.5), radius: 16, x: 0, y: 4)
                .shadow(color: Theme.accentB.opacity(DesignSystem.Opacity.glow * 0.3), radius: 24, x: 0, y: 6)
            
            // Enhanced content with refined typography spacing
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(title)
                    .font(Theme.title2.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(DesignSystem.Typography.titleLineHeight - 1.0)
                    .tracking(DesignSystem.Typography.normalTracking)
                
                Text(message)
                    .font(Theme.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(DesignSystem.Typography.bodyLineHeight - 1.0)
                    .tracking(DesignSystem.Typography.normalTracking)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .scaleEffect(isVisible ? 1.0 : 0.96)  // Subtle scale for premium feel
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button {
                    Haptics.tap()
                    action()
                } label: {
                    Text(actionTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .padding(.horizontal, DesignSystem.Spacing.xxl)
                .padding(.top, DesignSystem.Spacing.md)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxl)
        .onAppear {
            // Staggered entrance animation
            withAnimation(AnimationConstants.smoothSpring.delay(0.1)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            
            withAnimation(AnimationConstants.quickEase.delay(0.2)) {
                isVisible = true
            }
        }
    }
}

/// Agent 7: Predefined empty states for common scenarios
extension EmptyStateView {
    /// Agent 30: Enhanced empty state for no workouts using MicrocopyManager
    static func noWorkouts(action: @escaping () -> Void) -> EmptyStateView {
        let emptyState = MicrocopyManager.shared.emptyStateMessage(for: .noWorkouts)
        return EmptyStateView(
            icon: "figure.run",
            title: emptyState.title,
            message: emptyState.message,
            actionTitle: emptyState.actionTitle ?? "Start Workout",
            action: action
        )
    }
    
    /// Agent 13: Enhanced empty state for no focus sessions
    static func noFocusSessions(action: @escaping () -> Void) -> EmptyStateView {
        return EmptyStateView(
            icon: "brain.head.profile",
            title: "No Focus Sessions Yet",
            message: "Your focus journey starts with a single session. Begin your first Pomodoro timer session to build momentum.",
            actionTitle: "Start Focus Session",
            action: action
        )
    }
    
    /// Agent 30: Enhanced empty state for no history found using MicrocopyManager
    static func noHistoryFound(action: @escaping () -> Void) -> EmptyStateView {
        let emptyState = MicrocopyManager.shared.emptyStateMessage(for: .noHistoryFound)
        return EmptyStateView(
            icon: "magnifyingglass",
            title: emptyState.title,
            message: emptyState.message,
            actionTitle: emptyState.actionTitle ?? "Clear Filters",
            action: action
        )
    }
    
    /// Agent 30: Enhanced empty state for no exercises found using MicrocopyManager
    static func noExercisesFound(action: @escaping () -> Void) -> EmptyStateView {
        let emptyState = MicrocopyManager.shared.emptyStateMessage(for: .noExercisesFound)
        return EmptyStateView(
            icon: "figure.run.circle",
            title: emptyState.title,
            message: emptyState.message,
            actionTitle: emptyState.actionTitle ?? "Clear Filters",
            action: action
        )
    }
    
    /// Agent 30: Enhanced empty state for no achievements using MicrocopyManager
    static func noAchievements() -> EmptyStateView {
        let emptyState = MicrocopyManager.shared.emptyStateMessage(for: .noAchievements)
        return EmptyStateView(
            icon: "trophy",
            title: emptyState.title,
            message: emptyState.message,
            actionTitle: emptyState.actionTitle,
            action: nil
        )
    }
    
    /// Agent 30: Enhanced empty state for no insights using MicrocopyManager
    static func noInsights() -> EmptyStateView {
        let emptyState = MicrocopyManager.shared.emptyStateMessage(for: .noInsights)
        return EmptyStateView(
            icon: "chart.bar.xaxis",
            title: emptyState.title,
            message: emptyState.message,
            actionTitle: emptyState.actionTitle,
            action: nil
        )
    }
    
    /// Agent 30: Enhanced empty state for no goals using MicrocopyManager
    static func noGoals(action: @escaping () -> Void) -> EmptyStateView {
        let emptyState = MicrocopyManager.shared.emptyStateMessage(for: .noGoals)
        return EmptyStateView(
            icon: "target",
            title: emptyState.title,
            message: emptyState.message,
            actionTitle: emptyState.actionTitle ?? "Create Goal",
            action: action
        )
    }
    
    /// Empty state for loading data
    static func loadingData() -> EmptyStateView {
        EmptyStateView(
            icon: "hourglass",
            title: "Loading...",
            message: "Please wait while we load your data.",
            actionTitle: nil,
            action: nil
        )
    }
}

/// Agent 7: Inline empty state for cards
struct InlineEmptyState: View {
    let icon: String
    let message: String
    @State private var isVisible = false
    
    init(icon: String, message: String) {
        self.icon = icon
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.xlarge, weight: .light))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 5)
        .onAppear {
            withAnimation(AnimationConstants.quickEase) {
                isVisible = true
            }
        }
    }
}

