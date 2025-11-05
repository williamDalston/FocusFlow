import SwiftUI

struct OrbFieldView: View {
    struct Orb: Identifiable {
        let id = UUID()
        var x: CGFloat; var y: CGFloat
        var size: CGFloat
        var blur: CGFloat
        var opacity: Double
    }

    @State private var orbs: [Orb] = []
    private var count: Int { ProcessInfo.processInfo.isLowPowerModeEnabled ? 10 : 18 }

    var body: some View {
        TimelineView(.animation) { _ in
            GeometryReader { geo in
                ZStack {
                    ForEach(orbs) { o in
                        Circle()
                            .fill(.white.opacity(0.9))
                            .frame(width: o.size, height: o.size)
                            .blur(radius: o.blur)
                            .opacity(o.opacity)
                            .position(x: o.x, y: o.y)
                            .blendMode(.plusLighter)
                    }
                }
                .onAppear { seed(in: geo.size) }
                // iOS 16+ compatible onChange
                .onChange(of: geo.size) { newSize in
                    seed(in: newSize)
                }
                .drawingGroup() // offscreen render for smooth blending
            }
        }
        .allowsHitTesting(false)
    }

    private func seed(in size: CGSize) {
        guard !UIAccessibility.isReduceMotionEnabled else { orbs = []; return }
        var new: [Orb] = []
        for _ in 0..<count {
            let s = CGFloat.random(in: 44...150)
            new.append(.init(
                x: .random(in: 0...max(size.width, 1)),
                y: .random(in: 0...max(size.height, 1)),
                size: s,
                blur: .random(in: 8...22),
                opacity: .random(in: 0.05...0.18)
            ))
        }
        orbs = new
        withAnimation(.linear(duration: 16).repeatForever(autoreverses: true)) {
            for i in orbs.indices {
                orbs[i].x += CGFloat.random(in: -26...26)
                orbs[i].y += CGFloat.random(in: -26...26)
            }
        }
    }
}
