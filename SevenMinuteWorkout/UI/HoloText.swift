import SwiftUI

struct HoloText: View {
    let text: String
    @State private var phase: CGFloat = 0

    var body: some View {
        Text(text)
            .font(.largeTitle.bold())
            .overlay {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.95),
                        Color(hue: 0.55, saturation: 0.7, brightness: 1),
                        Color(hue: 0.85, saturation: 0.7, brightness: 1),
                        Color(hue: 0.15, saturation: 0.7, brightness: 1),
                        .white
                    ],
                    startPoint: UnitPoint(x: 0 - phase, y: 0.2),
                    endPoint:   UnitPoint(x: 1 - phase, y: 0.8)
                )
                .blendMode(.overlay)
                .mask(Text(text).font(.largeTitle.bold()))
            }
            .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: phase)
            .onAppear { if !UIAccessibility.isReduceMotionEnabled { phase = 1 } }
            .accessibilityLabel(Text(text))
    }
}
