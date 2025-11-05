import SwiftUI

/// SwiftUI Launch Screen to eliminate black letterbox bands
struct LaunchScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Use the same background as your main app
            LinearGradient(
                colors: [
                    Color(hue: 0.55, saturation: 0.98, brightness: 0.85), // masculineAccentA
                    Color(hue: 0.48, saturation: 1.0, brightness: 0.88),  // masculineAccentB
                    Color(hue: 0.62, saturation: 0.95, brightness: 0.78), // masculineAccentC
                    Color(hue: 0.55, saturation: 0.98, brightness: 0.85)  // masculineAccentA
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // App branding
            VStack(spacing: 20) {
                Image(systemName: "sparkles.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Ritual7")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LaunchScreenView()
}
