import SwiftUI

/// Agent 3: Preset Selector View - Choose from predefined Pomodoro presets
struct PresetSelectorView: View {
    @EnvironmentObject private var preferencesStore: FocusPreferencesStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPreset: PomodoroPreset?
    
    var body: some View {
        NavigationStack {
            contentView
        }
    }
    
    private var contentView: some View {
        ZStack {
            ThemeBackground()
            presetList
        }
        .navigationTitle("Pomodoro Presets")
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
    
    private var presetList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(PomodoroPreset.allCases), id: \.id) { preset in
                    presetCard(for: preset)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }
    
    private func presetCard(for preset: PomodoroPreset) -> some View {
        PresetCard(
            preset: preset,
            isSelected: selectedPreset == preset
        ) {
            selectedPreset = preset
            preferencesStore.updateSelectedPreset(preset)
            Haptics.tap()
        }
    }
}

// MARK: - Preset Card

private struct PresetCard: View {
    let preset: PomodoroPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GlassCard(material: .ultraThinMaterial) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: preset.icon)
                        .font(.system(size: DesignSystem.IconSize.xlarge, weight: .bold))
                        .foregroundStyle(isSelected ? Theme.accentA : Theme.textSecondary)
                        .frame(width: DesignSystem.IconSize.xxlarge, height: DesignSystem.IconSize.xxlarge)
                        .background(
                            Circle()
                                .fill(isSelected ? Theme.accentA.opacity(0.2) : Color.clear)
                        )
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(preset.displayName)
                                .font(Theme.headline)
                                .foregroundStyle(Theme.textPrimary)
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accentA)
                                    .font(Theme.headline)
                            }
                            
                            Spacer()
                            
                            Text("~\(Int(preset.focusDuration / 60)) min")
                                .font(Theme.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                        }
                        
                        Text(preset.description)
                            .font(Theme.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Details
                        HStack(spacing: 12) {
                            Label("\(Int(preset.focusDuration / 60)) min focus", systemImage: "brain.head.profile")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("\(Int(preset.shortBreakDuration / 60)) min break", systemImage: "pause.circle")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("\(preset.cycleLength) cycles", systemImage: "arrow.clockwise")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.statBox, style: .continuous)
                    .stroke(isSelected ? Theme.accentA : Theme.strokeOuter, lineWidth: isSelected ? DesignSystem.Border.emphasis : DesignSystem.Border.subtle)
            )
        }
        .buttonStyle(.plain)
    }
}


