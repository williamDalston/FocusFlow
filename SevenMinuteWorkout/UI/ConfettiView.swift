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
            c.birthRate = 6
            c.lifetime = 6
            c.velocity = 180
            c.velocityRange = 120
            c.emissionLongitude = .pi
            c.emissionRange = .pi / 6
            c.spin = 3.5
            c.spinRange = 1.0
            c.scale = 0.6
            c.scaleRange = 0.3
            c.color = color.cgColor
            c.contents = image?.cgImage
            return c
        }

        let colors: [UIColor] = [.systemPink, .systemTeal, .systemYellow, .systemPurple, .white]
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
