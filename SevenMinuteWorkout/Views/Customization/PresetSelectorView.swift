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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
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
                        .font(.system(size: 32))
                        .foregroundStyle(isSelected ? Theme.accentA : Theme.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(isSelected ? Theme.accentA.opacity(0.2) : Color.clear)
                        )
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(preset.displayName)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accentA)
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Text("~\(preset.estimatedMinutes) min")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                        }
                        
                        Text(preset.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Details
                        HStack(spacing: 12) {
                            Label("\(preset.exerciseIndices.count) exercises", systemImage: "figure.run")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("\(Int(preset.exerciseDuration))s", systemImage: "timer")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Label("\(Int(preset.restDuration))s rest", systemImage: "pause.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Theme.accentA : Theme.strokeOuter, lineWidth: isSelected ? 2 : 0.8)
            )
        }
        .buttonStyle(.plain)
    }
}


