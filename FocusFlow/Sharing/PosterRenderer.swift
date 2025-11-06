import SwiftUI

struct PosterView: View {
    let quote: String
    let date: Date

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, Color(hue: 0.65, saturation: 0.5, brightness: 0.35)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 18) {
                Text(date.formatted(date: .complete, time: .omitted))
                    .font(.caption.smallCaps())
                    .foregroundStyle(.white.opacity(0.7))
                Text(quote)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Spacer()
                Text("Ritual7")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.vertical, 40)
        }
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 600))
        .aspectRatio(4/5, contentMode: .fit)
        .drawingGroup()
        .accessibilityHidden(true)
    }
}

extension View {
    func renderAsUIImage(scale: CGFloat = 2.0) -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage ?? UIImage()
    }
}
