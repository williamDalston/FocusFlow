import SwiftUI

/// Minimal confetti using CAEmitterLayer via UIViewRepresentable.
/// It's lightweight and safe to call occasionally.
struct ConfettiView: UIViewRepresentable {
    @Binding var trigger: Bool

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard trigger else { return }
        
        // Use DispatchQueue to avoid modifying state during view update
        DispatchQueue.main.async {
            trigger = false
        }
        
        emitConfetti(in: uiView)
    }

    private func emitConfetti(in view: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 2)

        func cell(_ color: UIColor, _ image: UIImage?) -> CAEmitterCell {
            let c = CAEmitterCell()
            c.birthRate = 8  // Increased for more celebration
            c.lifetime = 8  // Longer lifetime for more presence
            c.velocity = 200  // Enhanced velocity
            c.velocityRange = 140  // More variation
            c.emissionLongitude = .pi
            c.emissionRange = .pi / 4  // Wider spread
            c.spin = 4.0  // More spin for dynamic feel
            c.spinRange = 1.5  // More variation
            c.scale = 0.7  // Slightly larger
            c.scaleRange = 0.4  // More size variation
            c.color = color.cgColor
            c.contents = image?.cgImage
            c.alphaSpeed = -0.1  // Fade out smoothly
            c.alphaRange = 0.2  // Some opacity variation
            return c
        }

        // Enhanced color palette with theme colors
        let colors: [UIColor] = [
            UIColor(Theme.accentA),
            UIColor(Theme.accentB),
            UIColor(Theme.accentC),
            .systemPink,
            .systemTeal,
            .systemYellow,
            .systemPurple,
            .white
        ]
        let square = UIImage(systemName: "square.fill")
        let circle = UIImage(systemName: "circle.fill")
        emitter.emitterCells = colors.flatMap { [
            cell($0, square),
            cell($0, circle)
        ] }

        view.layer.addSublayer(emitter)

        // Stop emission after a brief burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            emitter.birthRate = 0
        }
        // Remove the layer to avoid buildup
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            emitter.removeFromSuperlayer()
        }
    }
}
