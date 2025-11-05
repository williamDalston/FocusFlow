import SwiftUI

/// Agent 2: Achievements View - Display all achievements and progress
struct AchievementsView: View {
    @ObservedObject var achievementManager: AchievementManager
    @EnvironmentObject private var theme: ThemeStore
    @State private var selectedFilter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case unlocked = "Unlocked"
        case locked = "Locked"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header
                header
                
                // Filter
                filterPicker
                
                // Achievement grid
                achievementGrid
            }
            .contentPadding()
        }
        .background(ThemeBackground())
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("\(achievementManager.unlockedAchievements.count) / \(Achievement.allCases.count)")
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
                .monospacedDigit()
            
            Text("Achievements Unlocked")
                .font(Theme.subheadline)
                .foregroundStyle(.secondary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                    
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(Theme.accentA.gradient)
                        .frame(width: geometry.size.width * completionPercentage)
                }
            }
            .frame(height: DesignSystem.Spacing.sm)
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                )
        )
        .cardShadow()
    }
    
    private var completionPercentage: Double {
        Double(achievementManager.unlockedAchievements.count) / Double(Achievement.allCases.count)
    }
    
    // MARK: - Filter Picker
    
    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(FilterType.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Achievement Grid
    
    private var achievementGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.lg) {
            ForEach(filteredAchievements) { achievement in
                AchievementCard(
                    achievement: achievement,
                    isUnlocked: achievementManager.unlockedAchievements.contains(achievement),
                    progress: achievementManager.progressForAchievement(achievement)
                )
            }
        }
    }
    
    private var filteredAchievements: [Achievement] {
        switch selectedFilter {
        case .all:
            return Achievement.allCases
        case .unlocked:
            return Achievement.allCases.filter { achievementManager.unlockedAchievements.contains($0) }
        case .locked:
            return Achievement.allCases.filter { !achievementManager.unlockedAchievements.contains($0) }
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: Double
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                        ? achievement.color.opacity(DesignSystem.Opacity.subtle)
                        : Color.gray.opacity(DesignSystem.Opacity.subtle * 0.5)
                    )
                    .frame(width: DesignSystem.Spacing.xxxl * 1.25, height: DesignSystem.Spacing.xxxl * 1.25)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundStyle(
                        isUnlocked
                        ? achievement.color
                        : Color.gray.opacity(DesignSystem.Opacity.medium)
                    )
            }
            
            // Title
            Text(achievement.title)
                .font(Theme.headline)
                .foregroundStyle(
                    isUnlocked
                    ? Theme.textPrimary
                    : Color.gray.opacity(DesignSystem.Opacity.strong)
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Description
            Text(achievement.description)
                .font(Theme.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Progress bar (for locked achievements)
            if !isUnlocked && progress > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5)
                            .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                        
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small * 0.5)
                            .fill(achievement.color.opacity(DesignSystem.Opacity.medium))
                            .frame(width: geometry.size.width * progress)
                            .animation(AnimationConstants.smoothSpring, value: progress)
                    }
                }
                .frame(height: DesignSystem.Spacing.xs)
                
                Text("\(Int(progress * 100))%")
                    .font(Theme.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            
            // Rarity badge
            if isUnlocked {
                rarityBadge
            }
            
            // Share button (only for unlocked achievements)
            if isUnlocked {
                Button {
                    WorkoutShareManager.shared.shareAchievement(
                        title: achievement.title,
                        description: achievement.description,
                        icon: achievement.icon
                    )
                    Haptics.tap()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(Theme.caption)
                        .foregroundStyle(achievement.color)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .cardPadding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(
                    isUnlocked
                    ? .ultraThinMaterial
                    : Color.gray.opacity(DesignSystem.Opacity.subtle * 0.25)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .stroke(
                            isUnlocked
                            ? achievement.color.opacity(DesignSystem.Opacity.subtle * 1.5)
                            : Color.gray.opacity(DesignSystem.Opacity.subtle),
                            lineWidth: isUnlocked ? DesignSystem.Border.emphasis : DesignSystem.Border.subtle
                        )
                )
        )
        .cardShadow()
        .opacity(isUnlocked ? 1.0 : DesignSystem.Opacity.strong)
    }
    
    private var rarityBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: rarityIcon)
                .font(Theme.caption2)
            Text(rarityText)
                .font(Theme.caption2)
        }
        .foregroundStyle(rarityColor)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(rarityColor.opacity(DesignSystem.Opacity.subtle))
        )
    }
    
    private var rarityIcon: String {
        switch achievement.rarity {
        case .common: return "circle.fill"
        case .uncommon: return "star.fill"
        case .rare: return "star.circle.fill"
        case .epic: return "crown.fill"
        case .legendary: return "sparkles"
        }
    }
    
    private var rarityText: String {
        switch achievement.rarity {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .yellow
        }
    }
}

// MARK: - Recent Achievements View

struct RecentAchievementsView: View {
    @ObservedObject var achievementManager: AchievementManager
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        if !achievementManager.recentUnlocks.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Recent Achievements")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(achievementManager.recentUnlocks.prefix(5)) { achievement in
                            RecentAchievementCard(achievement: achievement)
                        }
                    }
                }
            }
            .cardPadding()
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .stroke(Theme.strokeOuter, lineWidth: DesignSystem.Border.subtle)
                    )
            )
            .cardShadow()
        }
    }
}

struct RecentAchievementCard: View {
    let achievement: Achievement
    @EnvironmentObject private var theme: ThemeStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(achievement.color)
                .frame(width: DesignSystem.IconSize.xxlarge, height: DesignSystem.IconSize.xxlarge)
                .background(
                    Circle()
                        .fill(achievement.color.opacity(DesignSystem.Opacity.subtle))
                )
            
            Text(achievement.title)
                .font(Theme.caption)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                        .stroke(achievement.color.opacity(DesignSystem.Opacity.light), lineWidth: DesignSystem.Border.standard)
                )
        )
        .shadow(color: Theme.enhancedShadow.opacity(DesignSystem.Opacity.subtle * 0.5), 
               radius: DesignSystem.Shadow.small.radius * 0.5, 
               y: DesignSystem.Shadow.small.y * 0.5)
    }
}


