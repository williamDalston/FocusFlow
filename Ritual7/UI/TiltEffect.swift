import SwiftUI

struct TiltEffect: ViewModifier {
    @State private var tilt: CGSize = .zero
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(Double(tilt.width / 8)), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(Double(-tilt.height / 12)), axis: (x: 1, y: 0, z: 0))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            tilt = CGSize(width: min(max(v.translation.width, -24), 24),
                                          height: min(max(v.translation.height, -24), 24))
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { tilt = .zero }
                    }
            )
            // DragGesture doesn't interfere with tap gestures/clicks, so mouse clicks work fine
    }
}
extension View { func tilt() -> some View { modifier(TiltEffect()) } }
