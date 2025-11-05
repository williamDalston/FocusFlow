import SwiftUI

// Subtle overlays you can reuse on cards, posters, modals.

struct Hairline: View {
    let cornerRadius: CGFloat
    var opacity: CGFloat = 0.18
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(Color.white.opacity(opacity), lineWidth: 1)
    }
}

struct InnerShine: View {
    let cornerRadius: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [Theme.strokeInner, Color.white.opacity(0.05)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: 1.4
            )
            .blendMode(.screen)
    }
}

// A tiny helper to clamp a max readable width for any container.
struct ReadableWidth: ViewModifier {
    var max: CGFloat = 600
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: max)
            .padding(.horizontal)
    }
}

extension View {
    func readableWidth(_ max: CGFloat = 600) -> some View {
        modifier(ReadableWidth(max: max))
    }
}
