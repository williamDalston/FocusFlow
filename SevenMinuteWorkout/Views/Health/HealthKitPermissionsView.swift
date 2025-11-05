import SwiftUI
import HealthKit

/// Agent 5: HealthKit Permissions View - UI for requesting HealthKit permissions
struct HealthKitPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKitStore = HealthKitStore.shared
    @State private var isRequesting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.accentA)
                        .padding(.top, 32)
                    
                    // Title
                    Text("Connect with Health")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("Connect your workouts with Apple Health to:")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 12) {
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
                        .padding(.horizontal)
                    }
                    
                    // Privacy note
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Text("Your health data is private and secure. We only write workout data to HealthKit.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            requestAuthorization()
                        } label: {
                            Label("Connect with Health", systemImage: "heart.fill")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                        .buttonStyle(PrimaryProminentButtonStyle())
                        .disabled(isRequesting || !healthKitStore.isAvailable)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Not Now")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(SecondaryGlassButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Health Integration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                healthKitStore.checkAuthorizationStatus()
            }
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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accentA)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    HealthKitPermissionsView()
}


