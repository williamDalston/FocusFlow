import SwiftUI

struct AutoGrowingTextEditor: View {
    @Binding var text: String
    var placeholder: String = ""
    var errorMessage: String? = nil
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusState.Binding var isFocused: Bool

    @State private var dynamicHeight: CGFloat = 44
    
    private var hasError: Bool {
        errorMessage != nil && !errorMessage!.isEmpty
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary.opacity(0.9))
                    .font(.body.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($isFocused)
                .frame(minHeight: dynamicHeight, maxHeight: horizontalSizeClass == .regular ? 200 : 150)
                .padding(.horizontal, 12) // Apply padding to TextEditor itself
                .padding(.vertical, 12)
                .scrollDisabled(false) // Enable scrolling
                .textSelection(.enabled) // Enable text selection
                .overlay(
                    ZStack {
                        // Background with glass effect
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Theme.accentA.opacity(hasError ? 0.0 : (isFocused ? DesignSystem.Opacity.subtle * 0.5 : 0.0)),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blendMode(.overlay)
                            )
                        
                        // Border with focus and error states
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: hasError
                                        ? [.red.opacity(DesignSystem.Opacity.strong), .red.opacity(DesignSystem.Opacity.medium)]
                                        : isFocused
                                        ? [Theme.accentA.opacity(DesignSystem.Opacity.strong), Theme.accentB.opacity(DesignSystem.Opacity.medium)]
                                        : [Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle), Theme.strokeOuter.opacity(DesignSystem.Opacity.borderSubtle * 0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: hasError ? DesignSystem.Border.emphasis : (isFocused ? DesignSystem.Border.standard * 1.5 : DesignSystem.Border.standard)
                            )
                            .shadow(
                                color: hasError
                                    ? .red.opacity(DesignSystem.Opacity.glow * 0.6)
                                    : isFocused
                                    ? Theme.accentA.opacity(DesignSystem.Opacity.glow * 0.8)
                                    : Color.clear,
                                radius: hasError || isFocused ? 4 : 0,
                                x: 0,
                                y: 0
                            )
                    }
                )
                .onTapGesture {
                    // Ensure focus and cursor appear immediately
                    isFocused = true
                }
                .onChange(of: text) { _ in
                    recalcHeight()
                }
                .onAppear { recalcHeight() }
                // Removed iPad features overlay for simplicity
            
            // Error message
            if hasError, let error = errorMessage {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(Theme.caption2)
                        .foregroundStyle(.red)
                    Text(error)
                        .font(Theme.caption2)
                        .foregroundStyle(.red.opacity(DesignSystem.Opacity.strong))
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.top, DesignSystem.Spacing.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func recalcHeight() {
        // More accurate height calculation considering text wrapping
        let lines = max(1, text.split(whereSeparator: \.isNewline).count)
        let maxLines = horizontalSizeClass == .regular ? 8 : 6
        let lineHeight = horizontalSizeClass == .regular ? 28.0 : 24.0
        let padding = 24.0 // 12pt top + 12pt bottom
        dynamicHeight = CGFloat(min(maxLines, lines)) * CGFloat(lineHeight) + padding
    }
}

// MARK: - Removed iPad Text Editor Features (simplified for publication)
