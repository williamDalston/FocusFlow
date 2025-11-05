import SwiftUI

/// Agent 6: Help View - In-app help and support section
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick help sections
                        quickHelpSection
                        
                        // Support options
                        supportSection
                        
                        // Additional resources
                        resourcesSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Help & Support")
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
    
    private var quickHelpSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Help")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "questionmark.circle.fill",
                    title: "Frequently Asked Questions",
                    description: "Find answers to common questions",
                    color: Theme.accentA
                ) {
                    // Navigation to FAQ would go here
                }
                
                HelpCard(
                    icon: "figure.run",
                    title: "Exercise Guide",
                    description: "Learn proper form and technique for each exercise",
                    color: Theme.accentB
                ) {
                    // Navigation to exercise guide would go here
                }
                
                HelpCard(
                    icon: "timer",
                    title: "How to Use the App",
                    description: "Get started with your first workout",
                    color: Theme.accentC
                ) {
                    // Navigation to tutorial would go here
                }
            }
        }
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    description: "Get help with any issues or questions",
                    color: .blue
                ) {
                    if let url = URL(string: "mailto:support@example.com") {
                        UIApplication.shared.open(url)
                    }
                }
                
                HelpCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Report an Issue",
                    description: "Let us know if you encounter any problems",
                    color: .orange
                ) {
                    if let url = URL(string: "mailto:feedback@example.com?subject=Issue Report") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "shield.fill",
                    title: "Safety Information",
                    description: "Important safety tips and guidelines",
                    color: .red
                ) {
                    // Show safety information
                }
                
                HelpCard(
                    icon: "star.fill",
                    title: "Rate the App",
                    description: "Love the app? Leave us a review!",
                    color: .yellow
                ) {
                    if let url = URL(string: "https://apps.apple.com/app/id\(getAppID())?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func getAppID() -> String {
        // Replace with your actual App Store ID
        return "YOUR_APP_ID"
    }
}

struct HelpCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.strokeOuter, lineWidth: 0.8)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


