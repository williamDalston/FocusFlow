import SwiftUI
import HealthKit

/// Agent 5: HealthKit Permissions View - UI for requesting HealthKit permissions
/// Enhanced with DesignSystem constants, accessibility, and smooth animations
struct HealthKitPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var healthKitStore = HealthKitStore.shared
    @State private var isRequesting = false
    @State private var errorMessage: String?
    @State private var showAnimation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xxl) {
                    // Icon with animation
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: DesignSystem.IconSize.huge, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accentA, Theme.accentB],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, DesignSystem.Spacing.xxl)
                        .scaleEffect(showAnimation ? 1.0 : 0.8)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .animation(
                            .spring(response: DesignSystem.AnimationDuration.smooth, dampingFraction: 0.7),
                            value: showAnimation
                        )
                    
                    // Title
                    Text("Connect with Health")
                        .font(.system(size: horizontalSizeClass == .regular ? 34 : 28, weight: DesignSystem.Typography.titleWeight))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    // Description
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Text("Connect your workouts with Apple Health to:")
                            .font(.headline.weight(DesignSystem.Typography.headlineWeight))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            FeatureRow(
                                icon: "figure.run",
                                text: "Track workouts in the Activity app"
                            )
                            
                            FeatureRow(
                                icon: "flame.fill",
                                text: "Contribute to your Activity rings"
                            )
                            
                            FeatureRow(
                                icon: "heart.fill",
                                text: "Record exercise minutes and calories"
                            )
                            
                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                text: "View workout history in Health app"
                            )
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                    
                    // Privacy note
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Text("Your health data is private and secure. We only write workout data to HealthKit.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(DesignSystem.Spacing.xs)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                                    .stroke(Color(.systemGray4), lineWidth: DesignSystem.Border.subtle)
                            )
                    )
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text(errorMessage)
                                .font(.caption)
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .fill(Color.red.opacity(DesignSystem.Opacity.subtle))
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Action buttons
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Button {
                            requestAuthorization()
                        } label: {
                            Label("Connect with Health", systemImage: "heart.fill")
                                .fontWeight(DesignSystem.Typography.headlineWeight)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.large.height)
                        }
                        .buttonStyle(PrimaryProminentButtonStyle())
                        .disabled(isRequesting || !healthKitStore.isAvailable)
                        .accessibilityLabel("Connect with Health")
                        .accessibilityHint("Double tap to connect your workouts with Apple Health")
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Not Now")
                                .fontWeight(DesignSystem.Typography.bodyWeight)
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.ButtonSize.standard.height)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                        .accessibilityLabel("Not Now")
                        .accessibilityHint("Double tap to skip connecting with Health for now")
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
            .navigationTitle("Health Integration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                    .accessibilityLabel("Skip")
                    .accessibilityHint("Double tap to skip connecting with Health")
                }
            }
            .onAppear {
                healthKitStore.checkAuthorizationStatus()
                // Trigger animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showAnimation = true
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility5)
        }
    }
    
    private func requestAuthorization() {
        guard !isRequesting else { return }
        
        isRequesting = true
        errorMessage = nil
        
        Task {
            await healthKitStore.requestAuthorization()
            
            await MainActor.run {
                isRequesting = false
                
                if healthKitStore.isAuthorized {
                    dismiss()
                } else {
                    errorMessage = "HealthKit permission was not granted. You can enable it later in Settings."
                }
            }
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: DesignSystem.IconSize.large))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accentA, Theme.accentB],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: DesignSystem.IconSize.large, height: DesignSystem.IconSize.large)
            
            Text(text)
                .font(.body.weight(DesignSystem.Typography.bodyWeight))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(DesignSystem.Spacing.xs)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - Preview

#Preview {
    HealthKitPermissionsView()
}


