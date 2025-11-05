import SwiftUI
import GoogleMobileAds
import UIKit

/// SwiftUI wrapper for Google banner with a loaded flag so we can show a tasteful fallback.
struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    @Binding var isLoaded: Bool

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController
        banner.delegate = context.coordinator
        
        // Add a small delay to ensure the view hierarchy is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            banner.load(Request())
        }
        
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) { }

    func makeCoordinator() -> Coordinator { Coordinator(isLoaded: $isLoaded) }

    final class Coordinator: NSObject, BannerViewDelegate {
        @Binding var isLoaded: Bool
        init(isLoaded: Binding<Bool>) { _isLoaded = isLoaded }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) { 
            print("✅ Banner ad loaded successfully")
            isLoaded = true 
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner ad failed to load:", error.localizedDescription)
            isLoaded = false
        }
    }
}

// MARK: - Beautiful Ad Integration

/// Glass morphism wrapper for ads that matches the app's aesthetic
struct AdGlassCard: View {
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
        GlassCard(material: .regularMaterial) {
            content
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

/// Premium-looking ad banner with glass morphism styling
struct PremiumAdBanner: View {
    let adUnitID: String
    @Binding var isLoaded: Bool
    @State private var showAd = false
    
    var body: some View {
        AdGlassCard {
            ZStack {
                // Background gradient that matches app theme
                LinearGradient(
                    colors: [
                        Color(hue: 0.55, saturation: 0.3, brightness: 0.15),
                        Color(hue: 0.48, saturation: 0.4, brightness: 0.12),
                        Color(hue: 0.62, saturation: 0.35, brightness: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(16)
                
                // Ad content
                if showAd {
                    AdBannerView(adUnitID: adUnitID, isLoaded: $isLoaded)
                        .frame(height: 50)
                        .opacity(isLoaded ? 1 : 0)
                        .accessibilityHidden(true)
                }
                
                // Fallback content when ad isn't loaded
                if !isLoaded || !showAd {
                    PremiumFallbackCard()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .frame(height: 70)
        .onAppear {
            // Delayed appearance for smoother UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showAd = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isLoaded)
    }
}

/// Beautiful fallback card that looks like premium content
struct PremiumFallbackCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Animated sparkle icon
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout Premium")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.textOnDark)
                
                Text("Unlock unlimited workouts & themes")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondaryOnDark)
            }
            
            Spacer()
            
            // Premium badge
            Text("PRO")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .onAppear {
            isAnimating = true
        }
        .onTapGesture {
            // Future: Navigate to premium features
            Haptics.gentle()
        }
    }
}

/// Floating mini ad that appears subtly at the bottom
struct FloatingMiniAd: View {
    let adUnitID: String
    @Binding var isLoaded: Bool
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            if isLoaded {
                // Show actual ad in a compact format
                AdBannerView(adUnitID: adUnitID, isLoaded: $isLoaded)
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)
            } else {
                // Show elegant fallback
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondaryOnDark)
                    
                    Text("Premium Features")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.textOnDark)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            // Subtle background blur
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0)) {
                isVisible = true
            }
        }
    }
}

// Legacy fallback for compatibility
struct HousePromoCard: View {
    var body: some View {
        AdGlassCard {
            HStack(spacing: 12) {
                Image(systemName: "sparkles.rectangle.stack.fill").font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep the good vibes")
                        .font(.subheadline.weight(.semibold))
                    Text("Share 7-Minute Workout with someone today.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Button("Share") {
                    let url = URL(string: "https://example.com")! // your marketing link later
                    let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    UIApplication.shared.firstKeyWindow?.rootViewController?.present(av, animated: true)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
            }
        }
    }
}

