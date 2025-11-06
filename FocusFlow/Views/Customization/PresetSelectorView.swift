import SwiftUI

/// Agent 3: Preset Selector View - Choose from predefined workout presets
struct PresetSelectorView: View {
    @EnvironmentObject private var preferencesStore: WorkoutPreferencesStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPreset: WorkoutPreset?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(WorkoutPreset.allCases) { preset in
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
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("Workout Presets")
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

// MARK: - Preset Card

private struct PresetCard: View {
    let preset: WorkoutPreset
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
                            
                            Text("~\(preset.estimatedMinutes) min")
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
                            Label("\(preset.exerciseIndices.count) exercises", systemImage: "figure.run")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("\(Int(preset.exerciseDuration))s", systemImage: "timer")
                                .font(Theme.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("\(Int(preset.restDuration))s rest", systemImage: "pause.circle")
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


