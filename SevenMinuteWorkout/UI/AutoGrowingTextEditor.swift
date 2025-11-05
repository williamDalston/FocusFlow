import SwiftUI

struct AutoGrowingTextEditor: View {
    @Binding var text: String
    var placeholder: String = ""
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FocusState.Binding var isFocused: Bool

    @State private var dynamicHeight: CGFloat = 44

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
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isFocused ? Theme.accentA : Theme.strokeOuter, lineWidth: isFocused ? 3.0 : 2.0)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial.opacity(0.5))
                        )
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
