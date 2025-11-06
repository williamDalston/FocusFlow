import SwiftUI

/// SwiftUI Launch Screen - Uses FocusFlow assets and theme system
/// Eliminates black letterbox bands and provides smooth launch experience
struct LaunchScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Use theme background gradient (matches main app)
            // This uses the Calm Focus theme by default
            Theme.backgroundGradient
                .ignoresSafeArea(.all)
            
            // Optional: Use launch background image for specific device sizes
            // Uncomment if you prefer using the launch background images
            /*
            if UIScreen.main.bounds.height >= 2778 {
                // 6.7" devices (iPhone 15 Pro Max, 14 Pro Max, etc.)
                Image("LaunchBackground-67")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            } else if UIScreen.main.bounds.height >= 2688 {
                // 6.5" devices (iPhone 11 Pro Max, XS Max, etc.)
                Image("LaunchBackground-65")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            } else {
                // Smaller devices - use gradient
                Theme.backgroundGradient
                    .ignoresSafeArea(.all)
            }
            */
            
            // App branding
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Pomodoro Timer")
                    .font(.title.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
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
