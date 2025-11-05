import SwiftUI

struct DepthLight: ViewModifier {
    var intensity: Double = 0.22
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(colors: [
                    .white.opacity(intensity),
                    .clear,
                    .black.opacity(intensity * 0.7)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .blendMode(.softLight)
            )
    }
}
extension View { func depthLight(_ i: Double = 0.22) -> some View { modifier(DepthLight(intensity: i)) } }
